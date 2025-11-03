unit DelphiMultithreadingBook0907.ThumbnailLoader;

interface

uses
  FMX.Graphics, System.Classes, System.Generics.Collections, System.Threading, System.Types,
  DelphiMultithreadingBook.CancellationToken;

type
  TThumbnailResult = record
    Index: Integer;
    Bitmap: TBitmap;
  end;

  TThumbnailResultArray = TArray<TThumbnailResult>;

  TOnThumbnailBatchProgress = reference to procedure(const Batch: TThumbnailResultArray);
  TOnThumbnailCompletion = reference to procedure(const Cancelled: Boolean);

  TThumbnailLoader = class
  public
    function LoadThumbnailsAsync(const FilePaths: TStringDynArray;
      const Token: ICancellationToken; OnProgress: TOnThumbnailBatchProgress;
      OnComplete: TOnThumbnailCompletion): ITask;
  end;

implementation

uses
  System.SysUtils, DelphiMultithreadingBook.Utils;

const
  THUMBNAIL_SIZE = 150;
  BATCH_SIZE = 10; // Send a batch every 10 images

{ TThumbnailLoader }

function TThumbnailLoader.LoadThumbnailsAsync(const FilePaths: TStringDynArray;
  const Token: ICancellationToken; OnProgress: TOnThumbnailBatchProgress;
  OnComplete: TOnThumbnailCompletion): ITask;
begin
  Result := TTask.Run(
    procedure
    var
      BatchBuffer: TList<TThumbnailResult>;
      i: Integer;
    begin
      BatchBuffer := TList<TThumbnailResult>.Create;
      try
        // Simple sequential loop for maximum stability
        for i := Low(FilePaths) to High(FilePaths) do
        begin
          Token.ThrowIfCancellationRequested;

          var OriginalBitmap := TBitmap.Create;
          var Thumbnail: TBitmap;
          try
            OriginalBitmap.LoadFromFile(FilePaths[i]);
            Thumbnail := OriginalBitmap.CreateThumbnail(THUMBNAIL_SIZE, THUMBNAIL_SIZE);
          finally
            OriginalBitmap.Free;
          end;

          var ResultItem: TThumbnailResult;
          ResultItem.Index := i;
          ResultItem.Bitmap := Thumbnail;
          BatchBuffer.Add(ResultItem);

          // If the buffer has reached batch size, or if this is the last image
          if (BatchBuffer.Count >= BATCH_SIZE) or (i = High(FilePaths)) then
          begin
            var BatchToSend := BatchBuffer.ToArray;
            BatchBuffer.Clear;
            TThread.Queue(nil,
              procedure
              begin
                if Assigned(OnProgress) then
                  OnProgress(BatchToSend);
                SetLength(BatchToSend, 0);
              end);
            // Yield CPU time to keep the UI 100% fluid
            Sleep(5);
          end;
        end;

        // Notify completion
        TThread.Queue(nil,
          procedure
          begin
            if Assigned(OnComplete) then
              OnComplete(False);
            BatchBuffer.Free;
          end);
      except
        on E: Exception do
        begin
          var IsCancelled := E is EOperationCancelled;
          TThread.Queue(nil,
            procedure
            begin
              if Assigned(OnComplete) then
                OnComplete(IsCancelled);
              LogWrite('Destroying BatchBuffer (Exception)(3)');
              BatchBuffer.Free;
            end);
        end;
      end;
    end);
end;

end.
