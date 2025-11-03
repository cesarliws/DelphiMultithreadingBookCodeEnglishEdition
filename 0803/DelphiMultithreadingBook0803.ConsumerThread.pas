unit DelphiMultithreadingBook0803.ConsumerThread;

interface

uses
  System.Classes;

type
  // Defines the callback type that the ConsumerThread will use to report
  // messages to the UI. The consumer thread will be responsible for ensuring
  // that this callback is executed in the context of the main thread.
  TConsumerMessageCallback = reference to procedure(const TextMessage: string);

  TConsumerThread = class(TThread)
  private
    // Callback for reporting messages
    FMessageCallback: TConsumerMessageCallback;
  protected
    procedure Execute; override;
  public
    // Constructor receives a callback for the UI
    constructor Create(MessageCallback: TConsumerMessageCallback);
  end;

implementation

uses
  System.TypInfo, System.SysUtils, System.Types, WinApi.Windows,
  DelphiMultithreadingBook0803.SharedData, DelphiMultithreadingBook.Utils;

{ TConsumerThread }

constructor TConsumerThread.Create(MessageCallback: TConsumerMessageCallback);
begin
  // Create suspended
  inherited Create(True);
  // Manual release management
  FreeOnTerminate := False;
  // Store the callback
  FMessageCallback := MessageCallback;
end;

procedure TConsumerThread.Execute;
var
  PopResult: TWaitResult;
  ProcessedCount: Integer;
  TextMessage: string;
  QueueSizeDummy: NativeInt;
begin
  ProcessedCount := 0;
  DebugLogWrite('Consumer: Starting to consume messages...');
  // Main loop, checks Terminated on each iteration
  while not Terminated do
  begin
    // Tries to get an item from the queue. The PopTimeout is configured in the TThreadedQueue's
    // constructor. This ensures the thread does not block indefinitely on PopItem and can
    // periodically check the Terminate signal.
    PopResult := ThreadSafeMessageQueue.PopItem(QueueSizeDummy, TextMessage);
    if PopResult = TWaitResult.wrSignaled then
    begin
      // An item was retrieved from the queue
      Inc(ProcessedCount);
      DebugLogWrite('Consumer: Processing "%s" (Total processed: %d)',
        [TextMessage, ProcessedCount]);
      // Invoke the callback to log to the UI
      if Assigned(FMessageCallback) then
        // The ConsumerThread now queues the callback for the Main UI
        TThread.Queue(nil,
          procedure
          begin
            FMessageCallback(Format('Consumer: Processed "%s"', [TextMessage]));
          end);
      // Simulate message processing
      Sleep(50 + Random(200));
    end
    else if PopResult = TWaitResult.wrTimeout then
    begin
      // Queue empty or timeout. Thread did not process anything this iteration.
      // Continue the loop to check Terminated again.
      DebugLogWrite('Consumer: Queue empty or timeout...');
    end
    // Other unexpected results from PopItem (wrAbandoned, wrError)
    else
    begin
      DebugLogWrite('Consumer: Unexpected error in PopItem (%s). Terminating...',
        [GetEnumName(TypeInfo(TWaitResult), Integer(PopResult))]);
        // Exit the loop in case of an unexpected error
      Break;
    end;
  end; // End of while not Terminated

  // After exiting the loop (because Terminated = True or an error in PopItem),
  // process any remaining items in the queue (drain the queue).
  // We use PopItem to get what's left.
  while ThreadSafeMessageQueue.PopItem(QueueSizeDummy, TextMessage) = TWaitResult.wrSignaled do
  begin
    Inc(ProcessedCount);
    DebugLogWrite('Consumer: Draining remaining item "%s"', [TextMessage]);
    if Assigned(FMessageCallback) then
      TThread.Queue(nil,
        procedure
        begin
          FMessageCallback(Format('Consumer: Drained "%s"', [TextMessage]));
        end);
  end;
  // Final message on shutdown
  if Assigned(FMessageCallback) then
    TThread.Queue(nil,
      procedure
      begin
        FMessageCallback(
          Format('Consumer: Service terminated. Total processed: %d',
          [ProcessedCount]));
      end);
  DebugLogWrite('Consumer: Terminated. Total processed: %d', [ProcessedCount]);
end;

end.
