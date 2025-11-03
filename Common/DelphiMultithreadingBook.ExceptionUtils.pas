unit DelphiMultithreadingBook.ExceptionUtils;

interface

uses
  System.SysUtils;

// This procedure can be used anywhere you need to inspect an exception,
// especially if there is a possibility of it being an EAggregateException.
procedure HandlePotentialAggregateException(E: Exception);

implementation

uses
  System.Threading, DelphiMultithreadingBook.Utils;

procedure HandlePotentialAggregateException(E: Exception);
var
  AggregateException: EAggregateException;
  InnerException: Exception;
begin
  if E is EAggregateException then
  begin
    AggregateException := EAggregateException(E);
    // You can also use AggregateException.ToString to extract the
    // messages from all aggregated exceptions at once.
    DebugLogWrite('Aggregate Error Detected: %s', [AggregateException.Message]);

    // By iterating over InnerExceptions,
    // you can get details of each individual failure.
    for InnerException in AggregateException do
    begin
      DebugLogWrite('  -> Inner Exception: %s: %s',
        [InnerException.ClassName, InnerException.Message]);
      // You can perform specific handling for each InnerException here,
      // such as logging it individually, displaying details in a UI list,
      // or even trying to identify error patterns.
    end;
  end
  else
    DebugLogWrite('Simple Error Detected: %s: %s', [E.ClassName, E.Message]);
end;

end.
