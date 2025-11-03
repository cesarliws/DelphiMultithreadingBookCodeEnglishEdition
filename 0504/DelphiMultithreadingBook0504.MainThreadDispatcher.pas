unit DelphiMultithreadingBook0504.MainThreadDispatcher;

interface

uses
  System.Classes, System.SysUtils, Winapi.Messages, Winapi.Windows;

type
  TMainThreadDispatcher = class(TComponent)
  private
    // Custom message
    const WM_RUN_POSTED = WM_APP + 1;
    // Singleton instance
    class var FInstance: TMainThreadDispatcher;
    class function GetInstance: TMainThreadDispatcher; static;
  private
    // Handle of the hidden window
    FWindowHandle: HWND;
    // This WndProc receives all messages.
    procedure WndProc(var Msg: TMessage);
    // Specific handler method for WM_RUN_POSTED
    procedure WMRunPosted(var Msg: TMessage);
  protected
    procedure Initialize; virtual;
    procedure Finalize; virtual;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;
    // Method to post the TProc to the main thread's message queue
    class procedure Post(Proc: TProc);
    // Property to access the single instance of the dispatcher
    class property Instance: TMainThreadDispatcher read GetInstance;
  end;

implementation

type
  PProc = ^TProc; // Pointer to TProc to pass via WParam

{ TMainThreadDispatcher }

constructor TMainThreadDispatcher.Create(Owner: TComponent);
begin
  inherited;
  Initialize; // Initializes the window handle
end;

destructor TMainThreadDispatcher.Destroy;
begin
  Finalize; // Deallocates the window handle
  inherited;
end;

procedure TMainThreadDispatcher.Initialize;
begin
  // Creates the hidden window
  FWindowHandle := AllocateHWnd(WndProc);
end;

procedure TMainThreadDispatcher.Finalize;
begin
  if FWindowHandle <> 0 then
    // Deallocates the window handle
    DeallocateHWnd(FWindowHandle);
  // Clears the handle
  FWindowHandle := 0;
end;

procedure TMainThreadDispatcher.WndProc(var Msg: TMessage);
begin
  if Msg.Msg = WM_RUN_POSTED then
    // Delegates the handling of the specific message to a dedicated method
    WMRunPosted(Msg)
  else
    // Passes other messages to the system's default WndProc
    Msg.Result := DefWindowProc(FWindowHandle, Msg.Msg, Msg.WParam, Msg.LParam);
end;

procedure TMainThreadDispatcher.WMRunPosted(var Msg: TMessage);
var
  ProcData: PProc;
  Proc: TProc;
begin
  // Retrieves the pointer to the TProc
  ProcData := PProc(Msg.WParam);
  // Use try..finally to ensure ProcData is freed
  try
    if Assigned(ProcData^) then
    begin
      // Dereference to get the TProc
      Proc := ProcData^;
      // Execute the anonymous method
      Proc();
    end;
  finally
    // Ensures that the memory allocated for the TProc pointer is always freed
    Dispose(ProcData);
  end;
end;

class function TMainThreadDispatcher.GetInstance: TMainThreadDispatcher;
begin
  // Creates the instance if it doesn't exist
  if not Assigned(FInstance) then
    FInstance := TMainThreadDispatcher.Create(nil);
  Result := FInstance;
end;

class procedure TMainThreadDispatcher.Post(Proc: TProc);
var
  ProcData: PProc;
begin
  // Allocates memory for the TProc pointer and stores the method
  New(ProcData);
  ProcData^ := Proc;
  // Posts the message to the hidden window, passing the pointer via WPARAM
  PostMessage(GetInstance.FWindowHandle, WM_RUN_POSTED, WParam(ProcData), 0);
end;

initialization
  TMainThreadDispatcher.FInstance := nil;

finalization
  // Ensures the singleton instance is freed on application shutdown
  if Assigned(TMainThreadDispatcher.FInstance) then
    TMainThreadDispatcher.FInstance.Free;

end.
