unit DelphiMultithreadingBook0705.WorkerThreads;

interface

uses
  System.Classes;

type
  TProducerThread = class(TThread)
  protected
    procedure Execute; override;
  end;

  TConsumerThread = class(TThread)
  protected
    procedure Execute; override;
  end;

implementation

uses
  System.SyncObjs, System.SysUtils,
  DelphiMultithreadingBook0705.SharedData, DelphiMultithreadingBook.Utils;

{ TProducerThread }

procedure TProducerThread.Execute;
var
  i: Integer;
  TaskName: string;
begin
  for i := 1 to 5 do
  begin
    if Terminated then
      Break;
    TaskName := Format('Task %d', [i]);
    QueueLock.Enter;
    try
      WorkQueue.Enqueue(TaskName);
      LogWrite('Producer: Added "%s" to the queue.', [TaskName]);
      // Uses Release to wake up ONE consumer thread that may be waiting
      QueueNotEmpty.Release;
    finally
      QueueLock.Leave;
    end;
    // Simulates time to generate the next task
    Sleep(500 + Random(1000));
  end;
  LogWrite('Producer: Finished production.');
end;

{ TConsumerThread }

procedure TConsumerThread.Execute;
var
  TaskName: string;
begin
  LogWrite('Consumer: Waiting for tasks...');
  while not Terminated do
  begin
    QueueLock.Enter;
    try
      // The while loop is essential for protection against "spurious wakeups"
      while (WorkQueue.Count = 0) and (not Terminated) do
      begin
        // Queue is empty. Releases the lock and sleeps until signaled.
        // The lock is passed as a parameter to WaitFor.
        QueueNotEmpty.WaitFor(QueueLock);
      end;
      if Terminated then
        Break;
      // Upon waking up, the lock has already been reacquired automatically.
      TaskName := WorkQueue.Dequeue;
    finally
      QueueLock.Leave;
    end;
    // The processing work is done outside the lock
    LogWrite('Consumer: Processing "%s"...', [TaskName]);
    // Simulates processing work
    Sleep(1000);
    LogWrite('Consumer: "%s" completed.', [TaskName]);
  end;
  LogWrite('Consumer: Terminated.');
end;

end.
