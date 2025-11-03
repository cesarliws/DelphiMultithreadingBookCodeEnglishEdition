unit DelphiMultithreadingBook0804.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  DelphiMultithreadingBook0804.BankAccount,
  DelphiMultithreadingBook0804.BankTransferWorker,
  DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    LogMemo: TMemo;
    StartDeadlockExampleButton: TButton;
    StartDeadlockPreventionButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartDeadlockExampleButtonClick(Sender: TObject);
    procedure StartDeadlockPreventionButtonClick(Sender: TObject);
  private
    FBankAccount101: TBankAccount;
    FBankAccount102: TBankAccount;
    // Explicit references for the two transfer threads
    FWorker1: TBankTransferWorker;
    FWorker2: TBankTransferWorker;
    // Counter to manage running threads
    FRunningWorkers: Integer;
    // Helper method to display balances in the LogMemo
    procedure DisplayBalances;
    // Termination handler for the transfer threads
    procedure TransferWorkerFinished(Sender: TObject);
    // Controls the state of the UI buttons
    procedure SetButtonStates(RunningState: TRunningState);
    // Method to finalize and free the workers
    procedure FinalizeWorkers;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.SyncObjs; // For TInterlocked

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');
  FBankAccount101 := TBankAccount.Create(101, 1000);
  FBankAccount102 := TBankAccount.Create(102, 1000);
  DisplayBalances;
  SetButtonStates(IsStopped);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FinalizeWorkers;
  FBankAccount101.Free;
  FBankAccount102.Free;
  UnregisterLogger;
end;

procedure TMainForm.FinalizeWorkers;
begin
  // Ensures that threads are terminated and freed safely.
  // The idiomatic pattern is to signal (if applicable), wait, and then free.
  if Assigned(FWorker1) then
  begin
    // The Terminate call is a no-op in this specific worker, as its Execute does not check the
    // Terminated property, but it's good practice to include it in a generic finalization method
    FWorker1.Terminate;
    // WaitFor waits for the thread to finish, regardless of the reason.
    // It returns immediately if the thread has already terminated.
    FWorker1.WaitFor;
    FWorker1.Free;
    FWorker1 := nil;
  end;

  if Assigned(FWorker2) then
  begin
    FWorker2.Terminate;
    FWorker2.WaitFor;
    FWorker2.Free;
    FWorker2 := nil;
  end;
end;

procedure TMainForm.DisplayBalances;
begin
  LogWrite('Current Balances -> Account %d: %d | Account %d: %d', [FBankAccount101.AccountNumber,
    FBankAccount101.GetBalance, FBankAccount102.AccountNumber, FBankAccount102.GetBalance]);
end;

procedure TMainForm.SetButtonStates(RunningState: TRunningState);
begin
  StartDeadlockExampleButton.Enabled := RunningState = IsStopped;
  StartDeadlockPreventionButton.Enabled := RunningState = IsStopped;
  Repaint;
end;

procedure TMainForm.TransferWorkerFinished(Sender: TObject);
var
  Worker: TBankTransferWorker;
begin
  // This event executes in the main thread (UI Thread)!
  if (csDestroying in ComponentState) then
    Exit;
  Worker := Sender as TBankTransferWorker;
  // Use the IsTransferDone flag for richer logging, indicating the operation's success.
  if Worker.IsTransferDone then
    LogWrite('Transfer Thread (ID: %d) finished SUCCESSFULLY.', [Worker.ThreadID])
  else
    LogWrite('Transfer Thread (ID: %d) finished WITH FAILURE (likely an exception).', [Worker.ThreadID]);

  // Atomically decrement the counter to manage the lifecycle.
  TInterlocked.Decrement(FRunningWorkers);
  // Only when the running threads counter reaches zero is the process considered complete.
  if FRunningWorkers = 0 then
  begin
    LogWrite('--- All transfer operations have been completed. ---');
    DisplayBalances;
    SetButtonStates(IsStopped);
  end;
end;

procedure TMainForm.StartDeadlockExampleButtonClick(Sender: TObject);
begin
  LogWrite('--- Starting DEADLOCK Example (without prevention) ---');
  LogWrite('This may freeze the application. You will probably have to terminate it manually.');
  FinalizeWorkers;
  // Reset balances
  FBankAccount101.Deposit(1000 - FBankAccount101.GetBalance);
  FBankAccount102.Deposit(1000 - FBankAccount102.GetBalance);
  DisplayBalances;
  SetButtonStates(IsRunning);
  // Set that two threads will be executed
  FRunningWorkers := 2;
  // Thread 1: 101 -> 102
  FWorker1 := TBankTransferWorker.Create(FBankAccount101, FBankAccount102, 100, False);
  FWorker1.OnTerminate := TransferWorkerFinished;
  FWorker1.Start;
  // Thread 2: 102 -> 101
  FWorker2 := TBankTransferWorker.Create(FBankAccount102, FBankAccount101, 100, False);
  FWorker2.OnTerminate := TransferWorkerFinished;
  FWorker2.Start;
  LogWrite('Transfer threads started (without prevention).');
end;

procedure TMainForm.StartDeadlockPreventionButtonClick(Sender: TObject);
begin
  LogWrite('--- Starting Example with DEADLOCK PREVENTION ---');
  FinalizeWorkers;
  // Reset balances
  FBankAccount101.Deposit(1000 - FBankAccount101.GetBalance);
  FBankAccount102.Deposit(1000 - FBankAccount102.GetBalance);
  DisplayBalances;
  SetButtonStates(IsRunning);
  // Set that two threads will be executed
  FRunningWorkers := 2;
  // Thread 1: 101 -> 102
  FWorker1 := TBankTransferWorker.Create(FBankAccount101, FBankAccount102, 100, True);
  FWorker1.OnTerminate := TransferWorkerFinished;
  FWorker1.Start;
  // Thread 2: 102 -> 101
  FWorker2 := TBankTransferWorker.Create(FBankAccount102, FBankAccount101, 100, True);
  FWorker2.OnTerminate := TransferWorkerFinished;
  FWorker2.Start;
  LogWrite('Transfer threads started (with prevention).');
end;

end.
