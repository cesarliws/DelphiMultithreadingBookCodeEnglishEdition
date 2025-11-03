unit DelphiMultithreadingBook0801.WorkerThread;

interface

uses
  System.Classes, System.SysUtils, WinApi.Windows,
  // WorkerThread directly depends on WorkerProcessor
  DelphiMultithreadingBook0801.WorkerProcessor;

type
  TWorkerThread = class(TThread)
  private
    FProcessor: TWorkerProcessor;
  protected
    procedure Execute; override;
  public
    // The constructor receives the configured WorkerProcessor instance (Dependency Injection)
    constructor Create(Processor: TWorkerProcessor);
    destructor Destroy; override;
    // Propagates cancellation to the processor it executes
    procedure RequestCancel;
    property Processor: TWorkerProcessor read FProcessor;
  end;

implementation

uses
  DelphiMultithreadingBook.Utils;

{ TWorkerThread }

constructor TWorkerThread.Create(Processor: TWorkerProcessor);
begin
  // Creates suspended, will be started explicitly by MainForm
  inherited Create(True);
  // FreeOnTerminate := False, as MainForm manages the life cycle
  FreeOnTerminate := False;
  // The thread receives the processor instance and assumes its ownership
  FProcessor := Processor;
end;

destructor TWorkerThread.Destroy;
begin
  // Frees the processor object when the thread is destroyed
  FProcessor.Free;
  inherited;
end;

procedure TWorkerThread.Execute;
begin
  DebugLogWrite('TWorkerThread: Starting processor execution...');
  try
    // Calls the processor's main business logic
    FProcessor.PerformLongCalculation;
  except
    on E: Exception do
    begin
      // Reports the error using the callback already configured in FProcessor
      FProcessor.ReportErrorFmt('Error in worker thread: %s', [E.Message]);
      DebugLogWrite('TWorkerThread: Unexpected error: %s', [E.Message]);
    end;
  end;
  DebugLogWrite('TWorkerThread: End of thread execution.');
end;

procedure TWorkerThread.RequestCancel;
begin
  // Propagates the cancellation request to the processor's business logic
  FProcessor.RequestCancel;
end;

end.
