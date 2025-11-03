unit DelphiMultithreadingBook1102.MainForm;

interface

uses
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.DApt.Intf, FireDAC.DatS,
  FireDAC.Phys, FireDAC.Phys.Intf, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Stan.Async, FireDAC.Stan.Def, FireDAC.Stan.Error,
  FireDAC.Stan.ExprFuncs, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Pool, FireDAC.UI.Intf, FireDAC.VCLUI.Wait, System.Classes, System.SysUtils,
  Vcl.Controls, Vcl.DBGrids, Vcl.Forms, Vcl.Grids, Vcl.StdCtrls,
  DelphiMultithreadingBook.CancellationToken, DelphiMultithreadingBook.Utils;

type
  TMainForm = class(TForm)
    FDConnectionTemplate: TFDConnection;
    FDMemTableUI: TFDMemTable;
    DataSourceUI: TDataSource;
    DBGridUI: TDBGrid;
    LoadDataButton: TButton;
    CancelButton: TButton;
    LogMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LoadDataButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
  private
    FCancellationTokenSource: TCancellationTokenSource;
    procedure OnDataReady(const DataStream: TStream);
    procedure OnDataError(const E: Exception);
    procedure SetButtonStates(IsRunning: Boolean);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  DelphiMultithreadingBook1102.DBWorkerThread;

procedure TMainForm.CancelButtonClick(Sender: TObject);
begin
  if Assigned(FCancellationTokenSource) then
    FCancellationTokenSource.Cancel;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  SetButtonStates(False);
  FDConnectionTemplate.ConnectionDefName := 'SQLite_Demo';
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FCancellationTokenSource) then
    FCancellationTokenSource.Cancel;
  if Assigned(FCancellationTokenSource) then
    FCancellationTokenSource.Free;
  UnregisterLogger;
end;

procedure TMainForm.LoadDataButtonClick(Sender: TObject);
begin
  LogWrite('> Requesting data from the database in the background...');
  SetButtonStates(True);
  FDMemTableUI.Close;
  // Create a new cancellation source for this operation
  if Assigned(FCancellationTokenSource) then
    FCancellationTokenSource.Free;
  FCancellationTokenSource := TCancellationTokenSource.Create;
  // Create and start the thread, passing the callbacks
  TDBWorkerThread.Create(FDConnectionTemplate.Params, 'SELECT * FROM Customers',
    FCancellationTokenSource.Token, OnDataReady, OnDataError);
end;

procedure TMainForm.OnDataError(const E: Exception);
begin
  if E is EOperationCancelled then
    LogWrite('Operation cancelled by user.')
  else
    LogWrite('ERROR: ' + E.Message);

  SetButtonStates(False);
end;

procedure TMainForm.OnDataReady(const DataStream: TStream);
begin
  try
    LogWrite('Data received. Updating the grid...');
    FDMemTableUI.LoadFromStream(DataStream, TFDStorageFormat.sfBinary);
    LogWrite('Grid updated!');
  finally
    // The stream is managed by the caller thread's scope and is freed
    // implicitly after this synchronized call completes. We should not free it here.
    SetButtonStates(False);
  end;
end;

procedure TMainForm.SetButtonStates(IsRunning: Boolean);
begin
  LoadDataButton.Enabled := not IsRunning;
  CancelButton.Enabled := IsRunning;
end;

end.
