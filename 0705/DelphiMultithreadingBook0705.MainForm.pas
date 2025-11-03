unit DelphiMultithreadingBook0705.MainForm;

interface

uses
  System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    StartButton: TButton;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
  private
    FConsumer: TThread;
    FProducer: TThread;
    procedure FinalizeThreads;
    procedure ProducerThreadTerminated(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.SysUtils, DelphiMultithreadingBook0705.SharedData,
  DelphiMultithreadingBook0705.WorkerThreads;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');
  // Creates and starts the Consumer, which will wait for work.
  FConsumer := TConsumerThread.Create(False);
  // Manual management
  FConsumer.FreeOnTerminate := False;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FinalizeThreads;
  UnregisterLogger;
end;

procedure TMainForm.FinalizeThreads;
begin
  // Finalizes the Producer first, if it exists
  if Assigned(FProducer) then
  begin
    FProducer.Terminate;
  end;
  // Then, finalizes the Consumer
  if Assigned(FConsumer) then
  begin
    FConsumer.Terminate;
    // Wakes up the consumer so it can check the Terminated flag
    QueueNotEmpty.Release;
    FConsumer.WaitFor;
    FConsumer.Free;
  end;
end;

procedure TMainForm.StartButtonClick(Sender: TObject);
begin
  if Assigned(FProducer) and (not FProducer.Finished) then
  begin
    LogWrite('Wait for the previous production to finish.');
    Exit;
  end;
  StartButton.Enabled := False;
  LogWrite('> Starting new task production...');
  // Creates a new producer for this cycle
  FProducer := TProducerThread.Create(False);
  // Producer is "fire and forget"
  FProducer.FreeOnTerminate := True;
  FProducer.OnTerminate := ProducerThreadTerminated;
end;

procedure TMainForm.ProducerThreadTerminated(Sender: TObject);
begin
  // When the producer finishes, we clean up the reference
  FProducer := nil;
  LogWrite('Production completed. You can start a new one.');
  StartButton.Enabled := True;
end;

end.
