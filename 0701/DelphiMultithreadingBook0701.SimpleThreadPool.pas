unit DelphiMultithreadingBook0701.SimpleThreadPool;

interface

uses
  System.Classes, System.Generics.Collections, System.SyncObjs, System.SysUtils;

type
  // Defines the type of "task" that the pool will execute
  TThreadPoolTask = TProc;

  // Internal class for the pool's threads
  TThreadPoolWorker = class(TThread)
  private
    // Reference to the parent pool (TSimpleThreadPool)
    FThreadPool: TObject;
    // Flag for graceful termination
    FShouldTerminate: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(Pool: TObject);
    // Method to signal termination
    procedure SignalTerminate;
  end;

  // Our simple Thread Pool
  TSimpleThreadPool = class(TObject)
  private
    FTaskQueue: TQueue<TThreadPoolTask>; // Task Queue
    FQueueLock: TCriticalSection;        // Queue protection
    FNewTaskEvent: TEvent;               // Signals new tasks
    FActiveTaskCount: NativeInt;         // Number of active tasks
    FMaxWorkers: Integer;                // Maximum number of workers
    FWorkerThreads: TObjectList<TThreadPoolWorker>; // List of threads in the pool
    FLastTaskId: Integer;
    function GetWorkerCount: Integer;
  public
    constructor Create(MaxWorkers: Integer = 0);
    destructor Destroy; override;
    function QueueTask(const Task: TThreadPoolTask): NativeInt;
    // Shutdown gracefully terminates the pool
    procedure Shutdown;
    property WorkerCount: Integer read GetWorkerCount;
    property ActiveTaskCount: Integer read FActiveTaskCount;
  end;

implementation

uses
  DelphiMultithreadingBook.Utils;

{ TThreadPoolWorker }

constructor TThreadPoolWorker.Create(Pool: TObject);
begin
  // Creates suspended
  inherited Create(True);
  // IMPORTANT: FreeOnTerminate := False so the pool manages the release
  FreeOnTerminate := False;
  FThreadPool := Pool;
  FShouldTerminate := False;
end;

procedure TThreadPoolWorker.SignalTerminate;
begin
  FShouldTerminate := True;
end;

procedure TThreadPoolWorker.Execute;
var
  Pool: TSimpleThreadPool;
  Task: TThreadPoolTask;
  TaskAvailable: Boolean;
begin
  Pool := FThreadPool as TSimpleThreadPool;
  DebugLogWrite('Worker Thread %d: Started.', [ThreadID]);
  // Main loop of the pool thread
  while not FShouldTerminate do
  begin
    TaskAvailable := False;
    Task := nil;
    Pool.FQueueLock.Enter;
    try
      if Pool.FTaskQueue.Count > 0 then
      begin
        // Workaround compiler error: E2010 Incompatible types: 'TProc' and 'Procedure of object'
        // Task := Pool.FTaskQueue.Dequeue;
        var TempTask := Pool.FTaskQueue.Dequeue;
        Task := TempTask;
        TaskAvailable := True;
        // If the queue empties, reset the event to wait again (ManualReset)
        if Pool.FTaskQueue.Count = 0 then
          Pool.FNewTaskEvent.ResetEvent;
      end
    finally
      Pool.FQueueLock.Leave;
    end;

    if TaskAvailable then
    begin
      // Increments active task counter (see **Topic 7.2**)
      TInterlocked.Increment(Pool.FActiveTaskCount);
      DebugLogWrite('Worker Thread %d: Executing task...', [ThreadID]);
      try
        Task(); // Executes the task!
      except
        on E: Exception do
        begin
          DebugLogWrite('Worker Thread %d: Error in task: %s', [ThreadID, E.Message]);
          // Reporting the error to the UI would be done here (TThread.Queue)
          // Ex: TThread.Queue(nil, procedure begin ShowMessage('Error!'); end);
        end;
      end;
      DebugLogWrite('Worker Thread %d: Task completed.', [ThreadID]);
      // Decrements active task counter (see **Topic 7.2**)
      TInterlocked.Decrement(Pool.FActiveTaskCount);
    end
    else
    begin
      // No task in the queue, wait for a new task
      DebugLogWrite('Worker Thread %d: Waiting for tasks...', [ThreadID]);
      // Blocks until a new item is signaled
      Pool.FNewTaskEvent.WaitFor(INFINITE);
    end;
  end; // FShouldTerminate loop
  DebugLogWrite('Worker Thread %d: Terminated gracefully.', [ThreadID]);
end;

{ TSimpleThreadPool }

constructor TSimpleThreadPool.Create(MaxWorkers: Integer);
var
  i: Integer;
  Worker: TThreadPoolWorker;
begin
  inherited Create;
  FMaxWorkers := MaxWorkers;
  if FMaxWorkers <= 0 then
    // At least the number of cores
    FMaxWorkers := TThread.ProcessorCount;
  FTaskQueue := TQueue<TThreadPoolTask>.Create;
  FQueueLock := TCriticalSection.Create;
  // ManualReset, Starts Not Signaled
  FNewTaskEvent := TEvent.Create(nil, True, False, '');
  // TObjectList<TThreadPoolWorker>.Create(True) so the list frees the objects when being freed
  FWorkerThreads := TObjectList<TThreadPoolWorker>.Create(True);
  FActiveTaskCount := 0;
  FLastTaskId := 0;
  // Creates the pool threads and starts them (now they don't auto-free)
  for i := 1 to FMaxWorkers do
  begin
    Worker := TThreadPoolWorker.Create(Self);
    FWorkerThreads.Add(Worker);
    // Starts the thread
    Worker.Start;
  end;
  DebugLogWrite('ThreadPool created with %d workers.', [FMaxWorkers]);
end;

destructor TSimpleThreadPool.Destroy;
begin
  // Ensures the pool is shut down upon destruction
  Shutdown;
  FWorkerThreads.Free;
  FNewTaskEvent.Free;
  FQueueLock.Free;
  FTaskQueue.Free;
  inherited;
end;

function TSimpleThreadPool.GetWorkerCount: Integer;
begin
  Result := FWorkerThreads.Count;
end;

function TSimpleThreadPool.QueueTask(const Task: TThreadPoolTask): NativeInt;
begin
  // Generates a unique and thread-safe task ID (see **Topic 7.2**)
  Result := TInterlocked.Increment(FLastTaskId);
  FQueueLock.Enter;
  try
    // Adds the task to the queue
    FTaskQueue.Enqueue(Task);
  finally
    FQueueLock.Leave;
  end;
  // Signals that there is a new task
  FNewTaskEvent.SetEvent;
end;

procedure TSimpleThreadPool.Shutdown;
var
  Worker: TThreadPoolWorker;
begin
  DebugLogWrite('ThreadPool: Starting Shutdown...');
  // Signals all threads that they must terminate
  for Worker in FWorkerThreads do
  begin
    Worker.SignalTerminate;
    // Wake up any worker threads that are idle and waiting on the event.
    FNewTaskEvent.SetEvent;
  end;
  // Waits for all threads to terminate (blocking)
  for Worker in FWorkerThreads do
  begin
    // If the thread has not terminated yet, wait for it.
    // Worker.Finished checks if Execute has finished.
    if not Worker.Finished then
      Worker.WaitFor;
  end;
  DebugLogWrite('ThreadPool: Shutdown completed. All threads terminated.');
end;

end.
