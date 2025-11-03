unit DelphiMultithreadingBook1102.DBWorkerThread;

interface

uses
  System.Classes, System.SysUtils, FireDAC.Stan.Def, FireDAC.Stan.Intf,
  DelphiMultithreadingBook.CancellationToken, DelphiMultithreadingBook1102.WorkerDataModule;

type
  TDataReadyEvent = reference to procedure(const DataStream: TStream);
  TDataErrorEvent = reference to procedure(const E: Exception);

  TDBWorkerThread = class(TThread)
  private
    FConnParams: TStrings;
    FSQL: string;
    FOnDataReady: TDataReadyEvent;
    FOnDataError: TDataErrorEvent;
    FToken: ICancellationToken;
    FDataModule: TWorkerDM;
  protected
    procedure Execute; override;
  public
    constructor Create(const ConnParams: TStrings; const SQL: string; const Token:
      ICancellationToken; OnDataReady: TDataReadyEvent; OnDataError: TDataErrorEvent);
    destructor Destroy; override;
  end;

implementation

uses
  FireDAC.Comp.Client;

{ TDBWorkerThread }

constructor TDBWorkerThread.Create(const ConnParams: TStrings; const SQL: string; const Token:
  ICancellationToken; OnDataReady: TDataReadyEvent; OnDataError: TDataErrorEvent);
begin
  // Thread will free itself
  FreeOnTerminate := True;
  FConnParams := TStringList.Create;
  FConnParams.AddStrings(ConnParams);
  FSQL := SQL;
  FToken := Token;
  FOnDataReady := OnDataReady;
  FOnDataError := OnDataError;
  FDataModule := TWorkerDM.Create(nil);
  // Starts immediately
  inherited Create(False);
end;

destructor TDBWorkerThread.Destroy;
begin
  FConnParams.Free;
  FDataModule.Free;
  inherited;
end;

procedure TDBWorkerThread.Execute;
var
  DataStream: TStream;
  ExceptionObj: TObject;
begin
  // Creates an instance of the DataModule for exclusive use by this thread
  try
    FDataModule.FDConnection.Params.AddStrings(FConnParams);
    FDataModule.FDConnection.Open;
    FToken.ThrowIfCancellationRequested;
    FDataModule.LoadData(FSQL);
    // Transfer the data to a TMemoryStream
    DataStream := TMemoryStream.Create;
    try
      FDataModule.FDQuery.SaveToStream(DataStream, TFDStorageFormat.sfBinary);
      DataStream.Position := 0;
      // Send the stream to the UI thread
      TThread.Synchronize(nil,
        procedure
        begin
          if Assigned(FOnDataReady) then
            FOnDataReady(DataStream);
        end);
    except
      begin
        // Ensures the stream is freed if the transfer failed
        DataStream.Free;
        // Re-raise the exception for the TThread mechanism
        raise;
      end;
    end;
  except
    on E: Exception do
    begin
      // Capture and pass the exception to the UI thread (Topic 4.5)
      ExceptionObj := AcquireExceptionObject;
      TThread.Synchronize(nil,
        procedure
        begin
          if Assigned(FOnDataError) then
            FOnDataError(ExceptionObj as Exception);
          // The UI thread is responsible for freeing the exception
          ExceptionObj.Free;
        end);
    end;
  end;
end;

end.
