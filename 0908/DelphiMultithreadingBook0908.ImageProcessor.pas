unit DelphiMultithreadingBook0908.ImageProcessor;

interface

uses
  System.Classes, System.Threading, System.Types, DelphiMultithreadingBook.CancellationToken;

type
  TOnProgress = reference to procedure;
  TOnCompletion = reference to procedure(const Cancelled: Boolean; const ElapsedMs: Int64);

  TImageProcessor = class
  public
    // The interface was simplified for the new scenario
    function ProcessImagesAsync(const FilePaths: TStringDynArray; const OutputDirectory: string;
      const Token: ICancellationToken; OnProgress: TOnProgress; OnComplete: TOnCompletion): ITask;
  end;

implementation

uses
  FMX.MediaLibrary, FMX.Platform,
  FMX.Graphics, FMX.Types, FMX.Utils, System.Diagnostics, System.IOUtils, System.Math,
  System.SyncObjs, System.SysUtils, System.UITypes, DelphiMultithreadingBook.Utils;

procedure SaveToPhotoLibrary(Bitmap: TBitmap; const FileName: string);
{$IFDEF MSWINDOWS}
begin
  Bitmap.SaveToFile(FileName);
{$ENDIF}
{$IFDEF ANDROID}
var
   PhotoGallery : IFMXPhotoLibrary;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXPhotoLibrary, PhotoGallery) then
  begin
     PhotoGallery.AddImageToSavedPhotosAlbum(Bitmap);
  end;
{$ENDIF}
end;

{ TImageProcessor }

function CreateGrayscaleCopy(const SourceBitmap: TBitmap): TBitmap;
var
  SourceMap, DestMap: TBitmapData;
  Y, X: Integer;
  SourceRow, DestRow: PAlphaColorArray;
  Pixel: TAlphaColor;
  Grayscale: Byte;
  NewPixelRec: TAlphaColorRec;
begin
  Result := TBitmap.Create(SourceBitmap.Width, SourceBitmap.Height);
  try
    if SourceBitmap.Map(TMapAccess.Read, SourceMap) and
       Result.Map(TMapAccess.Write, DestMap) then
    begin
      try
        for Y := 0 to SourceMap.Height - 1 do
        begin
          SourceRow := PAlphaColorArray(SourceMap.GetScanline(Y));
          DestRow := PAlphaColorArray(DestMap.GetScanline(Y));
          for X := 0 to SourceMap.Width - 1 do
          begin
            Pixel := SourceRow[X];
            Grayscale := Round(TAlphaColorRec(Pixel).R * 0.299 +
              TAlphaColorRec(Pixel).G * 0.587 + TAlphaColorRec(Pixel).B * 0.114);
            NewPixelRec.A := TAlphaColorRec(Pixel).A;
            NewPixelRec.R := Grayscale;
            NewPixelRec.G := Grayscale;
            NewPixelRec.B := Grayscale;
            DestRow[X] := NewPixelRec.Color;
          end;
        end;
      finally
        SourceBitmap.Unmap(SourceMap);
        Result.Unmap(DestMap);
      end;
    end
    else
      raise Exception.Create('Failed to map bitmaps for processing.');
  except
    Result.Free;
    raise;
  end;
end;

function TImageProcessor.ProcessImagesAsync(const FilePaths: TStringDynArray;
  const OutputDirectory: string; const Token: ICancellationToken;
  OnProgress: TOnProgress; OnComplete: TOnCompletion): ITask;
begin
  Result := TTask.Run(
    procedure
    var
      Stopwatch: TStopwatch;
      CustomPool: TThreadPool;
    begin
      CustomPool := nil;
      try
        Stopwatch := TStopwatch.StartNew;
        try
          // Configure the pool to use N-1 processors
          CustomPool := TThreadPool.Create;
          CustomPool.SetMaxWorkerThreads(Max(1, TThread.ProcessorCount - 1));

          TParallel.For(Low(FilePaths), High(FilePaths),
            procedure(i: Integer; LoopState: TParallel.TLoopState)
            var
              OriginalBitmap, GrayscaleBitmap: TBitmap;
              FromFile, ToFile: string;
            begin
              if Token.IsCancellationRequested then
              begin
                LoopState.Stop;
                Exit;
              end;

              FromFile := FilePaths[i];
              try
                OriginalBitmap := TBitmap.Create;
                try
                  OriginalBitmap.LoadFromFile(FromFile);
                  GrayscaleBitmap := CreateGrayscaleCopy(OriginalBitmap);
                  try
                    if OutputDirectory <> '' then
                    begin
                      ToFile := TPath.Combine(OutputDirectory,
                        TPath.GetFileNameWithoutExtension(FromFile) + '_grayscale.jpg');
                      SaveToPhotoLibrary(GrayscaleBitmap, ToFile);
                    end;
                  finally
                    GrayscaleBitmap.Free;
                  end;
                finally
                  OriginalBitmap.Free;
                end;
              except on
                E: Exception do
                begin
                  LogWrite('ERROR: ' + E.ToString);
                end;
              end;
              // Report progress safely
              TThread.Queue(nil,
                procedure
                begin
                  if Assigned(OnProgress) then
                    OnProgress;
                end);
            end, CustomPool);

          Stopwatch.Stop;
          Token.ThrowIfCancellationRequested;

          TThread.Queue(nil, procedure begin
            if Assigned(OnComplete) then
              OnComplete(False, Stopwatch.ElapsedMilliseconds);
          end);
        except
          on E: EOperationCancelled do
            TThread.Queue(nil, procedure begin
              if Assigned(OnComplete) then
                OnComplete(True, 0);
            end);
        end;
      finally
        if Assigned(CustomPool) then
          CustomPool.Free;
      end;
    end);
end;

end.
