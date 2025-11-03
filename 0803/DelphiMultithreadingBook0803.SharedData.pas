unit DelphiMultithreadingBook0803.SharedData;

interface

uses
  System.Generics.Collections; // TThreadedQueue<T>

var
  // Thread-safe message queue
  ThreadSafeMessageQueue: TThreadedQueue<string>;

implementation

const
  // We define a short timeout for Pop and Push operations
  // when the queue is full/empty to avoid long blocks.
  QUEUE_OPERATION_TIMEOUT_MS = 100;

initialization
  // Create the queue with a depth (capacity) of 10 items.
  ThreadSafeMessageQueue := TThreadedQueue<string>.Create(
    10, // Queue Capacity
    QUEUE_OPERATION_TIMEOUT_MS,  // PushTimeout
    QUEUE_OPERATION_TIMEOUT_MS); // PopTimeout

finalization
  ThreadSafeMessageQueue.Free;

end.
