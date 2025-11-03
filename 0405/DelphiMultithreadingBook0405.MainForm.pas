unit DelphiMultithreadingBook0405.MainForm;

interface

uses
  System.Classes, System.SysUtils, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  DelphiMultithreadingBook0405.WorkerWithExceptionThread,
  DelphiMultithreadingBook0405.WorkerWithErrorThread;

type
  TMainForm = class(TForm)
    RunThreadWithErrorButton: TButton;
    RunThreadWithExceptionButton: TButton;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure RunThreadWithErrorButtonClick(Sender: TObject);
    procedure RunThreadWithExceptionButtonClick(Sender: TObject);
  private
     // Reference for Unhandled Exception (`FatalException`)
    FWorkerWithException: TWorkerWithExceptionThread;
    // Reference for Intercepting Exceptions within the Thread (`try..except`)
    FWorkerWithErrorThread: TWorkerWithErrorThread;
    // Handler for TWorkerWithExceptionThread's OnTerminate
    // Unhandled Exception (`FatalException`)
    procedure WorkerWithExceptionThreadTerminated(Sender: TObject);
    // Handler for TWorkerWithErrorThread's OnTerminate
    // Intercepting Exceptions within the Thread (`try..except`)
    procedure WorkerWithErrorThreadTerminated(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  Vcl.Dialogs, DelphiMultithreadingBook.Utils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');
  LogWrite('Click "Run Thread with Unhandled Exception" to test FatalException.');
  LogWrite('Click "Run Thread with Handled Error" to test safe propagation.');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  // Since the threads are FreeOnTerminate, we don't need
  // to call WaitFor/Free here. We just unregister the logger.
  UnregisterLogger;
end;

procedure TMainForm.RunThreadWithExceptionButtonClick(Sender: TObject);
begin
  if Assigned(FWorkerWithException) then
  begin
    LogWrite('The FatalException thread is already running.');
    Exit;
  end;
  LogWrite('> Starting thread to raise an unhandled exception...');
  FWorkerWithException := TWorkerWithExceptionThread.Create(False);
  FWorkerWithException.FreeOnTerminate := True;
  FWorkerWithException.OnTerminate := WorkerWithExceptionThreadTerminated;
end;

procedure TMainForm.RunThreadWithErrorButtonClick(Sender: TObject);
begin
  if Assigned(FWorkerWithErrorThread) then
  begin
    LogWrite('The thread with a handled error is already running.');
    Exit;
  end;
  LogWrite('> Starting thread to catch and propagate an exception...');
  FWorkerWithErrorThread := TWorkerWithErrorThread.Create;
  FWorkerWithErrorThread.OnTerminate := WorkerWithErrorThreadTerminated;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  // If a thread is running, prevent closing, as these threads
  // might report an exception after the main form is gone.
  CanClose := not Assigned(FWorkerWithErrorThread)
    and not Assigned(FWorkerWithException);
  if not CanClose then
    LogWrite('*** Please wait for the thread to finish before closing the application!');
end;

procedure TMainForm.WorkerWithErrorThreadTerminated(Sender: TObject);
var
  WorkerThread: TWorkerWithErrorThread;
begin
  // This method is executed in the main thread (UI Thread)!
  WorkerThread := Sender as TWorkerWithErrorThread;
  LogWrite('Thread %d (With Error) TERMINATED.', [WorkerThread.ThreadID]);
  // Check if the thread stored an exception
  if Assigned(WorkerThread.Error) then
  begin
    LogWrite('THREAD ERROR (via Error property): %s', [WorkerThread.Error.Message]);
    ShowMessage(Format('Error detected in thread (via Error property): %s',
      [WorkerThread.Error.Message]));
    // IMPORTANT: The WorkerThread.Error object (acquired via AcquireExceptionObject)
    // will be freed by the TWorkerWithErrorThread's destructor when the
    // object is freed (due to FreeOnTerminate = True). Do not call Free here.
  end
  else
    LogWrite('Thread (With Error) completed with no reported errors.');
  // The thread has already freed itself, we just clear the reference
  FWorkerWithErrorThread := nil;
end;

procedure TMainForm.WorkerWithExceptionThreadTerminated(Sender: TObject);
var
  Error: Exception;
  WorkerThread: TWorkerWithExceptionThread;
begin
  // This event is executed in the main thread (UI thread)
  WorkerThread := Sender as TWorkerWithExceptionThread;
  LogWrite('Thread %d (FatalException) TERMINATED.', [WorkerThread.ThreadID]);
  // Check if the thread was terminated due to an unhandled exception
  if Assigned(WorkerThread.FatalException) then
  begin
    Error := Exception(WorkerThread.FatalException);
    LogWrite('--- FATAL exception detected in OnTerminate! ---');
    LogWrite('Message: %s', [Error.Message]);
    LogWrite('Class: %s', [Error.ClassName]);
    LogWrite('----------------------------------------');
    ShowMessage(Format('FATAL error in thread: %s', [Error.Message]));
    // IMPORTANT: It is not necessary to free WorkerThread.FatalException here;
    // TThread takes care of it when it is freed (due to FreeOnTerminate).
  end
  else
    LogWrite('Thread (FatalException) completed with no reported errors.');
  // Clear the thread reference in the form
  FWorkerWithException := nil;
end;

end.
