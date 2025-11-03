unit DelphiMultithreadingBook0303.MainForm;

interface

uses
  System.Classes, System.SyncObjs, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls;

type
  TMainForm = class(TForm)
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    // Mutex to ensure only one instance of the application can run
    FAppMutex: TMutex;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  Vcl.Dialogs, Winapi.Windows, DelphiMultithreadingBook.Utils;

const
  // A unique name for the Mutex, usually a GUID to avoid collisions.
  // To generate a GUID in Delphi: Use CTRL+SHIFT+G in the code editor and
  // remove the curly braces [].
  // Example GUID. REPLACE WITH YOUR OWN!
  MUTEX_NAME = '{F72C8429-6803-4D45-B48C-5124B25175F3}';

procedure TMainForm.FormCreate(Sender: TObject);
var
  AlreadyRunning: Boolean;
begin
  RegisterLogger(LogMemo.Lines);
  LogWrite('Application started, checking for single instance...');

  // Try to create (or open) the Mutex
  FAppMutex := TMutex.Create(
    nil,       // nil for default security attributes
    True,      // True for initial ownership
    MUTEX_NAME // Unique name of the Mutex
  );

  // If the Mutex already exists, GetLastError returns ERROR_ALREADY_EXISTS
  AlreadyRunning := GetLastError = ERROR_ALREADY_EXISTS;

  if AlreadyRunning then
  begin
    // If the Mutex already exists, the current instance of the TMutex object (FAppMutex)
    // is just a local wrapper. We do not have ownership of the system Mutex,
    // so we should not call Release. We just free our wrapper object.
    FAppMutex.Free;
    FAppMutex := nil;

    ShowMessage('Another instance of this application is already running.');

    // Prevents the form of the second instance from appearing and then disappearing.
    Application.ShowMainForm := False;

    // The use of `Application.Terminate` is intentional in this example
    // to close the second instance.
    Application.Terminate;
    // Exit FormCreate
    Exit;
  end
  else
  begin
    // If this is the first instance, it holds ownership of the Mutex until FormDestroy
    LogWrite('This is the only instance of the application.');
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  // The thread that created the Mutex should release it at the end
  // If FAppMutex was created and we are the only instance, release ownership.
  if Assigned(FAppMutex) then
  begin
    // Release ownership of the Mutex
    FAppMutex.Release;
    // Free the TMutex object
    FAppMutex.Free;
  end;
  UnregisterLogger;
end;

end.
