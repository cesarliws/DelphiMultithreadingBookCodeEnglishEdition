unit DelphiMultithreadingBook0306.Workers;

interface

uses
  System.Classes, System.SysUtils, System.SyncObjs, DelphiMultithreadingBook.Utils;

type
  TLockType = (CriticalSection, MultiReadExclusiveWrite);

  TReaderThread = class(TThread)
  private
    FLogCallback: TLogWriteCallback;
    FCriticalSection: TCriticalSection;
    FLightweightMREW: TLightweightMREW;
    FLockType: TLockType;
    FConfigList: TStrings;
    procedure ProcessCalculation;
  protected
    procedure Execute; override;
  public
    constructor Create(LockType: TLockType; ConfigList: TStrings; CriticalSection:
      TCriticalSection; var LightweightMREW: TLightweightMREW; LogCallback: TLogWriteCallback);
  end;

implementation

{ TReaderThread }

constructor TReaderThread.Create(LockType: TLockType; ConfigList: TStrings; CriticalSection:
  TCriticalSection; var LightweightMREW: TLightweightMREW; LogCallback: TLogWriteCallback);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FLockType := LockType;
  FConfigList := ConfigList;
  FCriticalSection := CriticalSection;
  FLightweightMREW := LightweightMREW;
  FLogCallback := LogCallback;
end;

procedure TReaderThread.Execute;
begin
  if FLockType = MultiReadExclusiveWrite then
  begin
    FLightweightMREW.BeginRead;
    try
      ProcessCalculation;
    finally
      FLightweightMREW.EndRead;
    end;
  end
  else
  begin
    FCriticalSection.Enter;
    try
      ProcessCalculation;
    finally
      FCriticalSection.Leave;
    end;
  end;
  FLogCallback(Format('Reader %d finished.', [ThreadID]));
end;

procedure TReaderThread.ProcessCalculation;
var
  i: Integer;
  CalcValue: Int64;
  TempString: string;
begin
  CalcValue := 0;
  for i := 1 to 250 do
  begin
    if FConfigList.Count > 0 then
    begin
      // Access the shared resource
      TempString := FConfigList[Random(FConfigList.Count)];
      // Simulate processing on the read data (to avoid being optimized out)
      CalcValue := CalcValue + Length(TempString);
    end;
    // Very short pause to simulate complexity and ensure the thread does not finish instantly.
    Sleep(2);
  end;
end;

end.
