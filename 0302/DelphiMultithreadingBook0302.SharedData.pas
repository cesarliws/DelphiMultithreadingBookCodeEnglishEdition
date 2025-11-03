unit DelphiMultithreadingBook0302.SharedData;

interface

uses
  System.Classes;

var
  // Shared resource for TMonitor
  SharedStringList: TStringList;

implementation

initialization
  // Creates (initializes) the shared resource
  SharedStringList := TStringList.Create;

finalization
  // Frees the shared resource
  SharedStringList.Free;

end.
