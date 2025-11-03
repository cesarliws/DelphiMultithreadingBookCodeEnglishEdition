unit DelphiMultithreadingBook1003.FractalCalculator;

interface

uses
  // The WinApi.Windows unit must come before the System.Classes unit
  WinApi.Windows, System.Classes, System.Threading, Vcl.Graphics;

type
  TOnFractalCompletion = reference to procedure(const Image: TBitmap; const ElapsedMs: Int64;
    const WasCancelled: Boolean);

  TFractalCalculator = class
  private
    FProcessorTask: ITask;
    function CalculateColor(x, y: Integer; Width, Height: Integer): TColor;
    function Map(value, start1, stop1, start2, stop2: Double): Double;
  public
    procedure GenerateMandelbrotAsync(const Width, Height: Integer; const UseParallel: Boolean;
      OnComplete: TOnFractalCompletion);
    procedure Cancel;
  end;

implementation

uses
  System.Diagnostics, System.SysUtils, System.Types, System.UITypes;

{ TFractalCalculator }

procedure TFractalCalculator.Cancel;
begin
  if Assigned(FProcessorTask) then
    FProcessorTask.Cancel;
end;

function TFractalCalculator.CalculateColor(x, y, Width, Height: Integer): TColor;
const
  MAX_ITERATIONS = 2500;
var
  a, b, ca, cb, aa, bb: Double;
  Index: Integer;
begin
  ca := Map(x, 0, Width, -2.5, 1);
  cb := Map(y, 0, Height, -1.5, 1.5);
  a := ca;
  b := cb;
  Index := 0;

  while (Index < MAX_ITERATIONS) do
  begin
    aa := a * a;
    bb := b * b;
    if (aa + bb) > 4.0 then
      Break;

    b := 2 * a * b + cb;
    a := aa - bb + ca;
    Inc(Index);
  end;

  if Index = MAX_ITERATIONS then
    Result := clBlack
  else
  begin
    var Bright := Map(Sqrt(Index / MAX_ITERATIONS), 0, 1, 0, 255);
    // Use RGB to construct the VCL color
    Result := TColor(RGB(Round(Bright), Round(Bright), Round(Bright) * 2 mod 255));
  end;
end;

procedure TFractalCalculator.GenerateMandelbrotAsync(const Width, Height: Integer;
  const UseParallel: Boolean; OnComplete: TOnFractalCompletion);
begin
  FProcessorTask := TTask.Run(
    procedure
    var
      Bitmap: TBitmap;
      Stopwatch: TStopwatch;
    begin
      Stopwatch := TStopwatch.StartNew;
      Bitmap := TBitmap.Create;
      try
        Bitmap.SetSize(Width, Height);
        Bitmap.PixelFormat := pf32bit;
        if UseParallel then
        begin
          TParallel.For(0, Height - 1,
            procedure(y: Integer; LoopState: TParallel.TLoopState)

              function IsTaskCanceled: Boolean;
              begin
                Result := (FProcessorTask.Status = TTaskStatus.Canceled);
                if Result then
                begin
                  LoopState.Stop;
                  FProcessorTask.CheckCanceled;
                end;
              end;
            var
              x: Integer;
              Row: PRGBQuad;
              VCLColor, RGBColor: TColor;
            begin
              if IsTaskCanceled then Exit;
              Row := PRGBQuad(Bitmap.ScanLine[y]);
              for x := 0 to Width - 1 do
              begin
                if IsTaskCanceled then Exit;
                VCLColor := CalculateColor(x, y, Width, Height);
                // Convert to pure RGB
                RGBColor := ColorToRGB(VCLColor);
                Row^.rgbRed   := GetRValue(RGBColor);
                Row^.rgbGreen := GetGValue(RGBColor);
                Row^.rgbBlue  := GetBValue(RGBColor);
                Row^.rgbReserved := 0;
                Inc(Row);
              end;
            end);
        end
        else
        begin
          // SEQUENTIAL VERSION
          for var y := 0 to Height - 1 do
          begin
            Self.FProcessorTask.CheckCanceled;
            var Row: PRGBQuad := PRGBQuad(Bitmap.ScanLine[y]);
            for var x := 0 to Width - 1 do
            begin
              var VCLColor := CalculateColor(x, y, Width, Height);
              var RGBColor := ColorToRGB(VCLColor);
              Row^.rgbRed   := GetRValue(RGBColor);
              Row^.rgbGreen := GetGValue(RGBColor);
              Row^.rgbBlue  := GetBValue(RGBColor);
              Row^.rgbReserved := 0;
              Inc(Row);
            end;
          end;
        end;
        Stopwatch.Stop;
        TThread.Queue(nil,
          procedure
          begin
            if Assigned(OnComplete) then
              OnComplete(Bitmap, Stopwatch.ElapsedMilliseconds, False);
          end);
      except
        on E: Exception do
        begin
          Bitmap.Free;
          TThread.Queue(nil,
            procedure
            begin
              if Assigned(OnComplete) then
                OnComplete(nil, 0, True);
            end);
        end;
      end;
    end);
end;

function TFractalCalculator.Map(value, start1, stop1, start2, stop2: Double): Double;
begin
  Result := start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1));
end;

end.
