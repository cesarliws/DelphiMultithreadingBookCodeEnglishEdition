unit DelphiMultithreadingBook0803.MainForm;

interface

uses
  System.Classes, System.Threading, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  DelphiMultithreadingBook0803.ConsumerThread, DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    ProduceMessagesButton: TButton;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ProduceMessagesButtonClick(Sender: TObject);
  private
    FConsumerThread: TConsumerThread;
    // Controls the producer task
    FProducerTask: ITask;
    // Method to be passed as a callback to the ConsumerThread
    procedure ConsumerMessagesCallback(const Text: string);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.SysUtils, WinApi.Windows, DelphiMultithreadingBook0803.SharedData;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started.');
  LogWrite('Consumer started and waiting for messages...');
  // 1. Create and start the Consumer ONCE. It will live with the application.
  FConsumerThread := TConsumerThread.Create(ConsumerMessagesCallback);
  FConsumerThread.Start;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FProducerTask) then
  begin
    FProducerTask.Cancel;
  end;
  // 3. Shut down the Consumer cleanly when the application closes.
  if Assigned(FConsumerThread) then
  begin
    FConsumerThread.Terminate;
    FConsumerThread.WaitFor;
    FConsumerThread.Free;
    FConsumerThread := nil;
  end;
  UnregisterLogger;
end;

procedure TMainForm.ConsumerMessagesCallback(const Text: string);
begin
  LogWrite(Text);
end;

procedure TMainForm.ProduceMessagesButtonClick(Sender: TObject);
begin
  if Assigned(FProducerTask) then
  begin
    LogWrite('Please wait for the previous batch of messages to be produced.');
    Exit;
  end;
  ProduceMessagesButton.Enabled := False;
  LogWrite('> Starting production of a new batch of 10 messages...');
  // 2. The "Production" is a lightweight TTask, not a heavyweight TThread.
  FProducerTask := TTask.Run(
    procedure
    var
      i: Integer;
      TextMessage: string;
    begin
      try
        try
          for i := 1 to 10 do
          begin
            TTask.CurrentTask.CheckCanceled;
            TextMessage := Format('Message %d', [i]);
            ThreadSafeMessageQueue.PushItem(TextMessage);
            DebugLogWrite('Producer: Added "%s" to the queue.', [TextMessage]);
            Sleep(100 + Random(500)); // Simulate production time
          end;
        except
          on E: EOperationCancelled do
            DebugLogWrite('Producer: Message production Canceled!');
          on E: Exception do
          begin
            TextMessage := E.ToString;
            TThread.Queue(nil,
              procedure
              begin
                if not (csDestroying in ComponentState) then
                  LogWrite(TextMessage);
              end);
          end;
        end;
      finally
        // At the end, just re-enable the button on the UI thread
        TThread.Queue(nil,
          procedure
          begin
            if csDestroying in ComponentState then
              Exit;
            if FProducerTask.Status = TTaskStatus.Completed then
              LogWrite('Batch of messages produced successfully.');
            ProduceMessagesButton.Enabled := True;
            FProducerTask := nil;
          end);
      end;
    end);
end;

end.
