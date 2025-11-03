Unit DelphiMultithreadingBook0806.LoggingThread;

interface

uses
  System.Classes;

type
  TLoggingThread = class(TThread)
  protected
    procedure Execute; override;
  public
    constructor Create; reintroduce;
  end;

implementation

uses
  System.SysUtils,
  CodeSiteLogging;

{ TLoggingThread }

constructor TLoggingThread.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;
end;

procedure TLoggingThread.Execute;
var
  i: Integer;
begin
  // Add tracing for the method, useful for debugging the flow
  CodeSite.TraceMethod('TLoggingThread.Execute', tmoTiming);
  CodeSite.Send('Worker Thread: Started.');
  try
    for i := 1 to 5 do
    begin
      if Terminated then
        Break;
      CodeSite.Send(Format('Worker Thread: Executing step %d.', [i]));
      Sleep(500);
    end;
    CodeSite.Send('Worker Thread: Finished.');
  except
    on E: Exception do
    begin
      // Log the complete exception
      CodeSite.Send('ERROR in Worker Thread:', E);
    end;
  end;
end;

end.
