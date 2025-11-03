unit DelphiMultithreadingBook1003.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Graphics, Vcl.ComCtrls,
  DelphiMultithreadingBook1003.FractalCalculator, DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    CancelButton: TButton;
    GenerateParallelButton: TButton;
    GenerateSequentialButton: TButton;
    ImageDisplay: TImage;
    LogMemo: TMemo;
    StatusBar: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GenerateSequentialButtonClick(Sender: TObject);
    procedure GenerateParallelButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
  private
    FFractalCalculator: TFractalCalculator;
    procedure RunGeneration(UseParallel: Boolean);
    procedure GenerationCompleted(const Image: TBitmap; const ElapsedMs: Int64;
      const WasCancelled: Boolean);
    procedure SetButtonStates(RunningState: TRunningState);
    procedure SetStatus(const Text: string);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.SysUtils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  SetButtonStates(IsStopped);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
  if Assigned(FFractalCalculator) then
    FFractalCalculator.Cancel;
end;

procedure TMainForm.GenerateParallelButtonClick(Sender: TObject);
begin
  RunGeneration(True);
end;

procedure TMainForm.GenerateSequentialButtonClick(Sender: TObject);
begin
  RunGeneration(False);
end;

procedure TMainForm.CancelButtonClick(Sender: TObject);
begin
  if Assigned(FFractalCalculator) then
    FFractalCalculator.Cancel;
end;

procedure TMainForm.RunGeneration(UseParallel: Boolean);
begin
  if Assigned(FFractalCalculator) then
    Exit;

  ImageDisplay.Picture.Bitmap := nil;
  if UseParallel then
    SetStatus('Generating in parallel, please wait...')
  else
    SetStatus('Generating sequentially (UI may freeze)...');

  SetButtonStates(IsRunning);
  // Force a UI update
  Repaint;
  FFractalCalculator := TFractalCalculator.Create;
  FFractalCalculator.GenerateMandelbrotAsync(ImageDisplay.Width, ImageDisplay.Height,
    UseParallel, GenerationCompleted);
end;

procedure TMainForm.GenerationCompleted(const Image: TBitmap;
  const ElapsedMs: Int64; const WasCancelled: Boolean);
begin
  try
    if csDestroying in ComponentState then
      Exit;

    if WasCancelled then
      SetStatus('Rendering cancelled.')
    else
    begin
      ImageDisplay.Picture.Bitmap.Assign(Image);
      SetStatus(Format('Rendering completed in %d ms', [ElapsedMs]));
    end;
  finally
    if Assigned(Image) then
      Image.Free; // Free the received bitmap
    SetButtonStates(IsStopped);
    if Assigned(FFractalCalculator) then
    begin
      FFractalCalculator.Free;
      FFractalCalculator := nil;
    end;
    CheckTasksFirstRun(True);
  end;
end;

procedure TMainForm.SetButtonStates(RunningState: TRunningState);
begin
  if csDestroying in ComponentState then Exit;
  GenerateSequentialButton.Enabled := RunningState = IsStopped;
  GenerateParallelButton.Enabled := RunningState = IsStopped;
  CancelButton.Enabled := RunningState = IsRunning;
end;

procedure TMainForm.SetStatus(const Text: string);
begin
  if csDestroying in ComponentState then Exit;
  StatusBar.SimpleText := Text;
  LogWrite(Text);
end;

end.
