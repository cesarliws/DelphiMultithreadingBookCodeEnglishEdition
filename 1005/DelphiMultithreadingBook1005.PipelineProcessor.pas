unit DelphiMultithreadingBook1005.PipelineProcessor;

interface

uses
  System.Classes, System.Threading, DelphiMultithreadingBook.CancellationToken;

type
  TPipelineState = (
    IdleState,
    DownloadingCustomersState,
    DownloadingProductsState,
    GeneratingReportState,
    CompletedState,
    FailedState,
    CanceledState,
    DestroyingState);

  TStateChangeEvent = reference to procedure(const State: TPipelineState; const Msg: string);

  TPipelineProcessor = class
  private
    FCurrentState: TPipelineState;
    FOrchestratorTask: ITask;
    FOnStateChange: TStateChangeEvent;
    FCustomerData: TStrings;
    FProductData: TStrings;
    FCancellationTokenSource: TCancellationTokenSource;
    FToken: ICancellationToken;
    procedure SetState(NewState: TPipelineState; const Msg: string = '');
    procedure RunStateMachine;
    procedure DoDownloadCustomerData;
    procedure DoDownloadProductData;
    procedure DoGenerateReport;
  public
    constructor Create(OnStateChange: TStateChangeEvent);
    destructor Destroy; override;
    procedure Run;
    procedure Cancel;
    property CurrentState: TPipelineState read FCurrentState;
  end;

implementation

uses
  System.SysUtils;

{ TPipelineProcessor }

constructor TPipelineProcessor.Create(OnStateChange: TStateChangeEvent);
begin
  FOnStateChange := OnStateChange;
  FCurrentState := IdleState;
  FCancellationTokenSource := TCancellationTokenSource.Create;
  FToken := FCancellationTokenSource.Token;
  // Ensures Randomize is called to get different results
  Randomize;
end;

destructor TPipelineProcessor.Destroy;
begin
  try
    FCurrentState := DestroyingState;
    Cancel;
  finally
    if Assigned(FCancellationTokenSource) then
      FCancellationTokenSource.Free;
    if Assigned(FCustomerData) then
      FCustomerData.Free;
    if Assigned(FProductData) then
      FProductData.Free;
    inherited;
  end;
end;

procedure TPipelineProcessor.Run;
begin
  if FCurrentState <> IdleState then
    Exit;
  FOrchestratorTask := TTask.Run(procedure
    begin
      // The state machine now runs inside a task
      RunStateMachine;
    end);
end;

procedure TPipelineProcessor.Cancel;
begin
  // Cancel the SOURCE, and the signal propagates throughout the pipeline
  if Assigned(FCancellationTokenSource) then
    FCancellationTokenSource.Cancel;
  if Assigned(FOrchestratorTask) then
    FOrchestratorTask.Wait(250);
end;

procedure TPipelineProcessor.SetState(NewState: TPipelineState;
  const Msg: string);
begin
  if FCurrentState = DestroyingState then Exit;
  FCurrentState := NewState;
  TThread.Queue(nil,
    procedure
    begin
      if (FCurrentState <> DestroyingState) and Assigned(FOnStateChange) then
        FOnStateChange(FCurrentState, Msg);
    end);
end;

procedure TPipelineProcessor.RunStateMachine;
begin
  try
    // Check the token, not the task reference
    FToken.ThrowIfCancellationRequested;
    case FCurrentState of
      IdleState:
        begin
          SetState(DownloadingCustomersState, 'Starting: Downloading Customers...');
          // Advance to the next state immediately
          RunStateMachine;
        end;

      DownloadingCustomersState:
        DoDownloadCustomerData;

      DownloadingProductsState:
        DoDownloadProductData;

      GeneratingReportState:
        DoGenerateReport;
    end;
  except
    on E: EOperationCancelled do
      SetState(CanceledState, 'Pipeline cancelled by user.');

    on E: Exception do
      SetState(FailedState, 'ERROR: ' + E.ToString);
  end;
end;

procedure TPipelineProcessor.DoDownloadCustomerData;
var
  i, Count: Integer;
  FirstNames, LastNames: TArray<string>;
begin
  FToken.ThrowIfCancellationRequested;
  // Simulate work
  Sleep(2000);

  FCustomerData := TStringList.Create;
  FirstNames := ['John', 'Mary', 'Peter', 'Anna', 'Charles', 'Mariana', 'Lucas'];
  LastNames := ['Smith', 'Jones', 'Pereira', 'Ferreira', 'Almeida', 'Lima'];

  // Generate 3 to 10 customers
  Count := Random(8) + 3;
  for i := 1 to Count do
  begin
    FToken.ThrowIfCancellationRequested;
    FCustomerData.Add(Format('Customer: %d - %s %s', [i, FirstNames[Random(Length(FirstNames))],
      LastNames[Random(Length(LastNames))]]));
  end;

  SetState(DownloadingProductsState,
    Format('%d Customers downloaded. Downloading Products...', [Count]));
  RunStateMachine;
end;

procedure TPipelineProcessor.DoDownloadProductData;
var
  i, Count: Integer;
  Products: TArray<string>;
begin
  FToken.ThrowIfCancellationRequested;
  Sleep(1500); // Simulate work

  FProductData := TStringList.Create;
  Products := ['Laptop', 'Mouse', 'Keyboard', 'Monitor', 'Webcam', 'SSD'];

  Count := Random(5) + 2; // Generate 2 to 6 products
  for i := 1 to Count do
  begin
    FToken.ThrowIfCancellationRequested;
    FProductData.Add(Format('Product: %d - %s', [100 + i, Products[Random(Length(Products))]]));
  end;

  SetState(GeneratingReportState, Format('%d Products downloaded. Generating Report...', [Count]));
  RunStateMachine;
end;

procedure TPipelineProcessor.DoGenerateReport;
var
  Report: TStrings;
begin
  FToken.ThrowIfCancellationRequested;
  Sleep(1000); // Simulate work

  Report := TStringList.Create;
  try
    Report.Add(Format('Report Generated: %d customers and %d products.',
      [FCustomerData.Count, FProductData.Count]));
    Report.Add('--- Customers ---');
    Report.AddStrings(FCustomerData);
    Report.Add('--- Products ---');
    Report.AddStrings(FProductData);
    Report.Add('-----------------');
    SetState(CompletedState, 'PIPELINE COMPLETED:' + sLineBreak + Report.Text);
  finally
    Report.Free;
  end;
end;

end.
