unit DelphiMultithreadingBook0404.PriorityWorker;

interface

uses
  System.Classes;

type
  TPriorityWorker = class(TThread)
  private
    FName: string;
  protected
    procedure Execute; override;
  public
    constructor Create(const Name: string; PriorityValue: TThreadPriority);
  end;

implementation

uses
  System.SysUtils, DelphiMultithreadingBook.Utils;

{ TPriorityWorker }

constructor TPriorityWorker.Create(const Name: string; PriorityValue: TThreadPriority);
begin
  // Starts immediately
  inherited Create(False);
  FreeOnTerminate := True;
  FName := Name;
  Priority := PriorityValue;
end;

procedure TPriorityWorker.Execute;
var
  // Using Int64 to avoid overflow in a long test
  WorkCounter: Int64;
begin
  WorkCounter := 0;
  while not Terminated do
  begin
    // Simulate a purely computational unit of work
    SimulateCPUWork(250);
    Inc(WorkCounter);
  end;
  // Report the result ONLY ONCE, at the end.
  LogWrite('%s finished. Work units completed: %d', [FName, WorkCounter]);
end;

end.
