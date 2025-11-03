unit DelphiMultithreadingBook0904.MainForm;

interface

uses
  FMX.Controls, FMX.Controls.Presentation, FMX.Forms, FMX.Layouts, FMX.Memo, FMX.Memo.Types,
  FMX.StdCtrls, FMX.ScrollBox, FMX.Types, System.Classes, System.Threading,
  DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    LogMemo: TMemo;
    Layout: TLayout;
    RequestSuccessButton: TButton;
    RequestFailButton: TButton;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RequestSuccessButtonClick(Sender: TObject);
    procedure RequestFailButtonClick(Sender: TObject);
  private
    FCurrentTask: ITask;
    procedure RunNetworkRequest(const URL: string);
    procedure SetButtonStates(RunningState: TRunningState);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  System.Net.HttpClient, System.SysUtils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogMemo.WordWrap := True;
  LogWrite('Application started.');
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
  // If a network task is still running when the form is destroyed, request its cancellation.
  if Assigned(FCurrentTask) then
  begin
    FCurrentTask.Cancel;
  end;
end;

procedure TMainForm.RequestSuccessButtonClick(Sender: TObject);
begin
  // Valid URL for a success test
  RunNetworkRequest('https://www.google.com');
end;

procedure TMainForm.RequestFailButtonClick(Sender: TObject);
begin
  // Invalid URL to force a network exception
  RunNetworkRequest('https://nonexistenturl.fail');
end;

procedure TMainForm.RunNetworkRequest(const URL: string);
begin
  if Assigned(FCurrentTask) then
  begin
    LogWrite('Please wait for the previous request to finish.');
    Exit;
  end;

  LogWrite('> Starting request to: ' + URL);
  SetButtonStates(IsRunning);

  FCurrentTask := TTask.Run(
    procedure
    var
      ExceptionObject: TObject;
      HTTPClient: THTTPClient;
      Response: string;
    begin
      HTTPClient := THTTPClient.Create;
      try
        try
          // Actual work logic: make the network request
          Response := HTTPClient.Get(URL).ContentAsString;
          // If we got here, the request was successful
          TThread.Queue(nil,
            procedure
            begin
              LogWrite('Success! Response received (first 100 characters):');
              LogWrite(Copy(Response, 1, 100) + '...');
            end);
        except
          on E: Exception do
          begin
            // Capture the network exception (or any other)
            ExceptionObject := AcquireExceptionObject;
            TThread.Queue(nil,
              procedure
              begin
                LogWrite('--- ERROR IN REQUEST ---');
                LogWrite('Exception: ' + (ExceptionObject as Exception).ClassName);
                LogWrite('Message: ' + (ExceptionObject as Exception).Message);
                // Free the exception object on the main thread
                ExceptionObject.Free;
              end);
          end;
        end;
      finally
        // Ensure the UI state is restored, no matter what happens
        TThread.Queue(nil,
          procedure
          begin
            SetButtonStates(IsStopped);
            FCurrentTask := nil;
          end);
        HTTPClient.Free;
      end;
    end);
end;

procedure TMainForm.SetButtonStates(RunningState: TRunningState);
begin
  if csDestroying in ComponentState then
    Exit;
  RequestSuccessButton.Enabled := RunningState = IsStopped;
  RequestFailButton.Enabled := RunningState = IsStopped;
end;

end.
