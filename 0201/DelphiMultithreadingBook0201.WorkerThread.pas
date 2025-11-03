unit DelphiMultithreadingBook0201.WorkerThread;

interface

uses
  System.Classes, Vcl.ComCtrls; // TProgressBar

type
  TWorkerThread = class(TThread)
  private
    FProgressBar: TProgressBar; // Reference to the ProgressBar on the UI
  protected
    procedure Execute; override;
  public
    // Passing VCL component references directly to a thread is not a recommended practice.
    // It is done here to simplify the introduction of other core concepts.
    // The recommended approach is to use callbacks to notify the Main Thread of updates.
    constructor Create(ProgressBar: TProgressBar);
  end;

implementation

uses
  System.SysUtils; // Sleep

{ TWorkerThread }

constructor TWorkerThread.Create(ProgressBar: TProgressBar);
begin
  // Create suspended
  inherited Create(True);
  FProgressBar := ProgressBar;
  // Manual memory management
  FreeOnTerminate := False;
end;

procedure TWorkerThread.Execute;
var
  i: Integer;
begin
  for i := 0 to 100 do
  begin
    // Check if the thread has been requested to terminate
    if Terminated then
    begin
      // Optional: Synchronize a final update to indicate interruption
      TThread.Synchronize(nil,
        procedure
        begin
          // Reset the progress bar
          FProgressBar.Position := 0;
          // Could add a message to the Log
        end);
      Break; // Exit the loop
    end;
    // Simulate a long-running task
    Sleep(100);
    // Safely update the progress on the UI, we use Queue here to not block the worker thread
    TThread.Queue(nil,
      procedure
      begin
        FProgressBar.Position := i;
      end);
  end;
  // Synchronize a final message on the UI when the work is done
  if not Terminated then
  begin
    TThread.Synchronize(nil,
      procedure
      begin
        FProgressBar.Position := 100;
        // Could add a "Completed!" message to the Log
      end);
  end;
end;

end.
