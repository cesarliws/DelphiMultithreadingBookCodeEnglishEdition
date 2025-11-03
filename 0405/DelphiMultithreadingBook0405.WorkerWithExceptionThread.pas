unit DelphiMultithreadingBook0405.WorkerWithExceptionThread;

interface

uses
  System.Classes;

type
  // Thread that does not handle Exceptions
  TWorkerWithExceptionThread = class(TThread)
  protected
    procedure Execute; override;
  end;

implementation

uses
  System.SysUtils, DelphiMultithreadingBook.Utils;

{ TWorkerWithExceptionThread }

procedure TWorkerWithExceptionThread.Execute;
begin
  LogWrite('WorkerWithExceptionThread: Starting work that will cause an error...');
  // Simulate some work
  Sleep(1000);
  // Intentionally raising an exception, WITHOUT CATCHING IT IN THIS METHOD.
  // This will cause TThread to set FatalException.
  raise Exception.Create('Exception generated in the worker thread (uncaught)!');
  // The code from here on will not be executed.
  LogWrite('WorkerWithExceptionThread: Work completed (this text will not appear).');
end;

end.
