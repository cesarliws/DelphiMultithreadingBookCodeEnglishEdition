unit DelphiMultithreadingBook1102.WorkerDataModule;

interface

uses
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet, FireDAC.DApt, FireDAC.DApt.Intf,
  FireDAC.DatS, FireDAC.Phys, FireDAC.Phys.Intf, FireDAC.Phys.SQLite,FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.Stan.Async, FireDAC.Stan.Def, FireDAC.Stan.Error,
  FireDAC.Stan.ExprFuncs, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Pool, FireDAC.Stan.StorageBin, FireDAC.UI.Intf, FireDAC.VCLUI.Wait,
  System.Classes, System.SysUtils;

type
  TWorkerDM = class(TDataModule)
    FDQuery: TFDQuery;
    FDStanStorageBinLink: TFDStanStorageBinLink;
    FDConnection: TFDConnection;
  public
    procedure LoadData(const SQL: string);
  end;

var
  WorkerDM: TWorkerDM;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}
{$R *.dfm}

{ TWorkerDM }

procedure TWorkerDM.LoadData(const SQL: string);
begin
  FDQuery.SQL.Text := SQL;
  FDQuery.Open;
end;

end.
