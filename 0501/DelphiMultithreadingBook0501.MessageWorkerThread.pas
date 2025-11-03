unit DelphiMultithreadingBook0501.MessageWorkerThread;

interface

uses
  System.Classes,
  Winapi.Windows,  // PostMessage, HWND
  Winapi.Messages; // WM_APP

type
  TMessageWorkerThread = class(TThread)
  private
    // Handle of the window to send messages to
    FTargetWindowHandle: HWND;
    FMessageCount: Integer;
  protected
    procedure Execute; override;
  public
    constructor Create(TargetWindowHandle: HWND; MessageCount: Integer = 5);
  end;

  PMessageData = ^TMessageData;
  TMessageData = record
    TextMessage: string;
  end;

const
  // Custom message to update the Memo
  WM_UPDATE_MEMO = WM_APP + 1;
  // Message to indicate task is done
  WM_TASK_DONE   = WM_APP + 2;

implementation

uses
  System.SysUtils, DelphiMultithreadingBook.Utils;

{ TMessageWorkerThread }

constructor TMessageWorkerThread.Create(TargetWindowHandle: HWND;  MessageCount: Integer = 5);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FTargetWindowHandle := TargetWindowHandle;
  FMessageCount := MessageCount
end;

procedure TMessageWorkerThread.Execute;
var
  i: Integer;
  MessageData: PMessageData;
begin
  DebugLogWrite('MessageWorkerThread: Starting work...');
  for i := 1 to FMessageCount do
  begin
    if Terminated then
      Break;
    // Allocate a pointer to the record
    New(MessageData);
    // Set the text message to be sent
    MessageData^.TextMessage := Format('Message Thread Progress: %d of %d', [i, FMessageCount]);
    // Send the message asynchronously.
    // WParam contains the pointer to MessageData.
    PostMessage(FTargetWindowHandle, WM_UPDATE_MEMO, WPARAM(MessageData), 0);
    // Simulate work
    Sleep(1000);
  end;
  // Signal that the task has finished
  PostMessage(FTargetWindowHandle, WM_TASK_DONE, 0, 0);
  DebugLogWrite('MessageWorkerThread: Work completed!');
end;

end.
