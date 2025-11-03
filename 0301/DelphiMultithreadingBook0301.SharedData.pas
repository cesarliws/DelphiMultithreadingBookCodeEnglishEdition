unit DelphiMultithreadingBook0301.SharedData;

interface

uses
  System.Classes, System.SyncObjs;

var
  // Shared resource: a list of strings
  SharedStringList: TStringList;
  // Critical Section object to protect the SharedStringList
  SharedStringListCriticalSection: TCriticalSection;

implementation

initialization
  // Create the Critical Section and the protected resource, in this order.
  SharedStringListCriticalSection := TCriticalSection.Create;
  SharedStringList := TStringList.Create;

finalization
  // Free the resources in the reverse order of creation.
  SharedStringList.Free;
  SharedStringListCriticalSection.Free;

end.

