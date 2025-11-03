program DelphiMultithreadingBook1105;

uses
  Vcl.Forms,
  DelphiMultithreadingBook1105.MainForm in 'DelphiMultithreadingBook1105.MainForm.pas' {MainForm},
  DelphiMultithreadingBook1105.WorkerDataModule in 'DelphiMultithreadingBook1105.WorkerDataModule.pas' {WorkerDM: TDataModule},
  DelphiMultithreadingBook1105.Entities in 'DelphiMultithreadingBook1105.Entities.pas',
  DelphiMultithreadingBook1105.Interfaces in 'DelphiMultithreadingBook1105.Interfaces.pas',
  DelphiMultithreadingBook1105.Repository in 'DelphiMultithreadingBook1105.Repository.pas',
  DelphiMultithreadingBook1105.Controller in 'DelphiMultithreadingBook1105.Controller.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas',
  DelphiMultithreadingBook1105.OrderView in 'DelphiMultithreadingBook1105.OrderView.pas' {Form1},
  DelphiMultithreadingBook1105.CustomerView in 'DelphiMultithreadingBook1105.CustomerView.pas' {Form2};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
