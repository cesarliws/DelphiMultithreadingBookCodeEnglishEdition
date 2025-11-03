unit DelphiMultithreadingBook0305.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  DelphiMultithreadingBook0305.Shared,
  DelphiMultithreadingBook0305.ProducerThread,
  DelphiMultithreadingBook0305.ConsumerThread;

type
  TMainForm = class(TForm)
    StartProducerConsumerButton: TButton;
    LogMemo: TMemo;
    StopConsumerButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartProducerConsumerButtonClick(Sender: TObject);
    procedure StopConsumerButtonClick(Sender: TObject);
  private
    // Variables to hold references to the Producer and Consumer threads
    FProducerThread: TProducerThread;
    FConsumerThread: TConsumerThread;
    procedure ProducerThreadTerminate(Sender: TObject);
    procedure ConsumerThreadTerminate(Sender: TObject);
    procedure FinalizeConsumer;
    procedure FinalizeProducer;
    procedure InitializeConsumer;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.SyncObjs, DelphiMultithreadingBook.Utils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started. Click the buttons to start the threads.');
  LogMemo.ScrollBars := ssVertical;
  StopConsumerButton.Enabled := False;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  // Terminate the Producer thread, if still active
  FinalizeProducer;
  // Terminate the Consumer thread, if still active
  FinalizeConsumer;
  UnregisterLogger;
end;

procedure TMainForm.StartProducerConsumerButtonClick(Sender: TObject);
begin
  StartProducerConsumerButton.Enabled := False;
  LogWrite('> Starting production of new messages...');
  InitializeConsumer;
  FinalizeProducer;
  // Ensures the event and queue are clear for a new production run
  QueueCriticalSection.Enter;
  try
    MessageQueue.Clear;
  finally
    QueueCriticalSection.Leave;
  end;
  // Ensures the event starts in a non-signaled state
  NewItemsEvent.ResetEvent;
  // Creates and starts a new Producer thread
  FProducerThread := TProducerThread.Create(LogWrite);
  FProducerThread.OnTerminate := ProducerThreadTerminate;
  LogWrite('New production started. Follow along in the Debug Output and LogMemo.');
end;

procedure TMainForm.StopConsumerButtonClick(Sender: TObject);
begin
  if Assigned(FConsumerThread) then
  begin
    LogWrite('Requesting shutdown of the Consumer Thread...');
    FConsumerThread.Terminate;
    // Signal to ensure the consumer exits the WaitFor
    NewItemsEvent.SetEvent;
    // The WaitFor and Free will be done in FormDestroy or in OnTerminate
    // itself if the consumer has nothing left to process and finishes on its own.
    // In this case, the consumer's OnTerminate already handles clearing
    // the reference.
    FinalizeConsumer;
    LogWrite('Newly produced messages will no longer be consumed.');
  end;
end;

procedure TMainForm.ProducerThreadTerminate(Sender: TObject);
begin
  // Synchronize with the main thread to update the UI
  TThread.ForceQueue(nil,
    procedure
    begin
      LogWrite('Producer Thread finished. Production completed.');
      // Re-enable the start button for a new production run.
      StartProducerConsumerButton.Enabled := True;
      // If the consumer is stopped, it will only generate new messages without consumption.
    end);
end;

// Handler for the Consumer's OnTerminate
procedure TMainForm.ConsumerThreadTerminate(Sender: TObject);
begin
  // Synchronize with the main thread to update the UI
  TThread.ForceQueue(nil,
    procedure
    begin
      LogWrite('Consumer Thread finished.');
      StopConsumerButton.Enabled := False;
      StartProducerConsumerButton.Enabled := True;
    end);
end;

procedure TMainForm.InitializeConsumer;
begin
  if not Assigned(FConsumerThread) then
  begin
    LogWrite('Consumer inactive. Recreating the consumer thread...');
    FConsumerThread := TConsumerThread.Create(LogWrite);
    FConsumerThread.OnTerminate := ConsumerThreadTerminate;
    StopConsumerButton.Enabled := True;
  end;
end;

procedure TMainForm.FinalizeConsumer;
begin
  if Assigned(FConsumerThread) then
  begin
    FConsumerThread.Terminate;
    NewItemsEvent.SetEvent; // Signal the consumer to exit WaitFor
    FConsumerThread.WaitFor;
    FConsumerThread.Free;
    FConsumerThread := nil;
  end;
end;

procedure TMainForm.FinalizeProducer;
begin
  if Assigned(FProducerThread) then
  begin
    FProducerThread.Terminate;
    FProducerThread.WaitFor;
    FProducerThread.Free;
    FProducerThread := nil;
  end;
end;

end.
