unit DelphiMultithreadingBook0504.AsyncHelpers;

interface

uses
  System.Classes, // TNotifyEvent
  System.SysUtils, // TProc, TProcedure,
  DelphiMultithreadingBook0504.MainThreadDispatcher; // TMainThreadDispatcher

// Helper methods to post code to the Main Thread asynchronously.
// RunAsync means "Execute asynchronously on the Main Thread".
// It does not create new threads.
procedure RunAsync(Proc: TProc); overload;
procedure RunAsync(Proc: TProcedure); overload;
procedure RunAsync(Sender: TObject; NotifyEvent: TNotifyEvent); overload;
procedure RunAsync(NotifyEvent: TNotifyEvent); overload;

implementation

procedure RunAsync(Proc: TProc);
begin
  // Dispatches the TProc directly to the Main Thread via the Dispatcher
  TMainThreadDispatcher.Post(Proc);
end;

procedure RunAsync(Proc: TProcedure);
begin
  // Wraps a TProcedure (which is not an object method)
  // into a TProc (anonymous method)
  TMainThreadDispatcher.Post(
    procedure
    begin
      Proc();
    end);
end;

procedure RunAsync(Sender: TObject; NotifyEvent: TNotifyEvent);
begin
  // Wraps a TNotifyEvent into a TProc, capturing the Sender
  TMainThreadDispatcher.Post(
    procedure
    begin
      NotifyEvent(Sender);
    end);
end;

procedure RunAsync(NotifyEvent: TNotifyEvent);
begin
  // Wraps a TNotifyEvent into a TProc, passing nil as the Sender
  TMainThreadDispatcher.Post(
    procedure
    begin
      NotifyEvent(nil);
    end);
end;

end.
