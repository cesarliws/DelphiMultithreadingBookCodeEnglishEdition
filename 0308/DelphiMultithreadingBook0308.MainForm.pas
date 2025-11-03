unit DelphiMultithreadingBook0308.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, DelphiMultithreadingBook0308.Worker;

type
  TMainForm = class(TForm)
    StartButton: TButton;
    CancelButton: TButton;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
  private
    FOrchestrator: TThread;
    FWorker: TWorkerWithCancel;
    procedure FinalizeThreads;
    procedure OrchestratorTerminated(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.SysUtils, Winapi.Windows, DelphiMultithreadingBook.Utils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FinalizeThreads;
  UnregisterLogger;
end;

procedure TMainForm.StartButtonClick(Sender: TObject);
begin
  if Assigned(FOrchestrator) then
  begin
    LogWrite('Test already in progress.');
    Exit;
  end;
  LogMemo.Lines.Clear;
  LogWrite('> Starting Worker and Orchestrator...');
  StartButton.Enabled := False;
  CancelButton.Enabled := True;
  FWorker := TWorkerWithCancel.Create;
  FWorker.Start;
  // Create an anonymous thread to orchestrate, to avoid blocking the UI
  FOrchestrator := TThread.CreateAnonymousThread(
    procedure
    var
      Handles: array[0..1] of THandle;
      WaitResult: DWORD;
    begin
      // Ensure the worker reference is valid at the start
      if not Assigned(FWorker) then
        Exit;
      // Index 0: Worker thread termination (Thread Handle)
      Handles[0] := FWorker.Handle;
      // Index 1: Cancellation event
      Handles[1] := FWorker.CancelEvent.Handle;
      // Wait for ANY of the two handles to be signaled
      WaitResult := WaitForMultipleObjects(2, @Handles, False, INFINITE);
      // Report the result to the UI safely
      TThread.Queue(nil, procedure
        begin
          // Only process the result if the form still exists
          if not (csDestroying in ComponentState) then
          begin
            case WaitResult of
              WAIT_OBJECT_0 + 0:
                LogWrite('Orchestrator: Worker finished on its own.');
              WAIT_OBJECT_0 + 1:
                LogWrite('Orchestrator: Cancellation signal received!');
            else
              LogWrite('Orchestrator: Error during wait.');
            end;
            FinalizeThreads;  // Cleanup
          end;
        end);
    end);
  // FUNDAMENTAL ASSIGNMENT: Tells the orchestrator to call
  // OrchestratorTerminated before self-destructing.
  FOrchestrator.OnTerminate := OrchestratorTerminated;
  // Start the orchestrator thread, which has FreeOnTerminate = True by default
  FOrchestrator.Start;
end;

procedure TMainForm.CancelButtonClick(Sender: TObject);
begin
  if Assigned(FWorker) then
  begin
    LogWrite('Firing cancellation event...');
    FWorker.CancelEvent.SetEvent;
    CancelButton.Enabled := False;
  end;
end;

procedure TMainForm.OrchestratorTerminated(Sender: TObject);
begin
  // The orchestrator thread has finished and is about to be freed.
  // This is the only safe time to clear our reference to it.
  FOrchestrator := nil;
end;

procedure TMainForm.FinalizeThreads;
begin
  // If the form is closed and the thread still exists, we ask it to terminate.
  // If it has already finished, FOrchestrator will be nil and nothing will happen.
  if Assigned(FOrchestrator) then
  begin
    FOrchestrator.Terminate;
  end;
  if Assigned(FWorker) then
  begin
    FWorker.Terminate;
    FWorker.CancelEvent.SetEvent;
    FWorker.Free;
    FWorker := nil;
  end;
  if not (csDestroying in ComponentState) then
  begin
    StartButton.Enabled := True;
    CancelButton.Enabled := False;
  end;
end;

end.
