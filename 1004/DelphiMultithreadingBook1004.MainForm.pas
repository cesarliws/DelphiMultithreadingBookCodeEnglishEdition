unit DelphiMultithreadingBook1004.MainForm;

interface

uses
  System.Classes, System.Threading, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls,
  DelphiMultithreadingBook.Utils, DelphiMultithreadingBook.CancellationToken;

type
  TMainForm = class(TForm)
    StartPipelineButton: TButton;
    CancelButton: TButton;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartPipelineButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
  private
    FOrchestratorTask: ITask;
    // Source to create and control the cancellation token
    FCancellationTokenSource: TCancellationTokenSource;
    procedure SetButtonStates(IsRunning: Boolean);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.SysUtils, DelphiMultithreadingBook1004.PipelineTasks;

procedure TMainForm.CancelButtonClick(Sender: TObject);
begin
  // Now, we cancel the SOURCE, and the signal propagates to all
  if Assigned(FCancellationTokenSource) then
  begin
    LogWrite('Requesting pipeline cancellation...');
    FCancellationTokenSource.Cancel;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  // Ensure cancellation on close
  if Assigned(FCancellationTokenSource) then
    FCancellationTokenSource.Cancel;
  // FOrchestratorTask.Wait would be ideal here to ensure the task finishes before the form
  // closes, but it can cause a deadlock
  // if the task tries to use TThread.Queue. Cancellation is already good protection.
  FCancellationTokenSource.Free;
  UnregisterLogger;
end;

procedure TMainForm.SetButtonStates(IsRunning: Boolean);
begin
  StartPipelineButton.Enabled := not IsRunning;
  CancelButton.Enabled := IsRunning;
end;

procedure TMainForm.StartPipelineButtonClick(Sender: TObject);
var
  Token: ICancellationToken;
begin
  if Assigned(FOrchestratorTask) then
    Exit;

  LogMemo.Lines.Clear;
  LogWrite('> Starting import pipeline...');
  SetButtonStates(True);
  // Create a new cancellation source for this run
  FCancellationTokenSource := TCancellationTokenSource.Create;
  Token := FCancellationTokenSource.Token;

  FOrchestratorTask := TTask.Run(
    procedure
    var
      CustomerFuture, ProductFuture: IFuture<TStrings>;
      ReportFuture: IFuture<string>;
      CustomerData, ProductData: TStrings;
      ReportResult: string;
    begin
      CustomerData := nil;
      ProductData := nil;
      try
        Token.ThrowIfCancellationRequested;

        LogWrite('Dispatching download of Customers and Products...');
        CustomerFuture := TPipelineTasks.LoadCustomersAsync(Token);
        ProductFuture := TPipelineTasks.LoadProductsAsync(Token);
        TTask.WaitForAll([CustomerFuture, ProductFuture]);

        Token.ThrowIfCancellationRequested;
        CustomerData := CustomerFuture.Value;
        ProductData := ProductFuture.Value;
        LogWrite('Downloads completed. Consolidating report...');

        ReportFuture := TPipelineTasks.GenerateOrderReportAsync(CustomerData, ProductData, Token);

        ReportResult := ReportFuture.Value;
        TThread.Queue(nil,
          procedure
          begin
            LogWrite('PIPELINE COMPLETED SUCCESSFULLY!');
            LogWrite(ReportResult);
          end);
      except
        on E: EOperationCancelled do
        begin
          TThread.Queue(nil,
            procedure
            begin
              LogWrite('PIPELINE CANCELLED BY USER.');
            end);
        end;
        on E: Exception do
        begin
          ReportResult := E.ToString;
          TThread.Queue(nil, procedure
            begin
              LogWrite('ERROR IN PIPELINE: ' + ReportResult);
            end);
        end;
      end;

      TThread.Queue(nil,
        procedure
        begin
          CustomerData.Free;
          ProductData.Free;
          if Assigned(FCancellationTokenSource) then
          begin
            FCancellationTokenSource.Free;
            FCancellationTokenSource := nil;
          end;

          FOrchestratorTask := nil;
          if not (csDestroying in ComponentState) then
            SetButtonStates(False);
        end);
    end);
end;

end.
