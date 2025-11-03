program DelphiMultithreadingBook0804;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0804.MainForm in 'DelphiMultithreadingBook0804.MainForm.pas' {MainForm},
  DelphiMultithreadingBook0804.BankAccount in 'DelphiMultithreadingBook0804.BankAccount.pas',
  DelphiMultithreadingBook0804.BankTransferWorker in 'DelphiMultithreadingBook0804.BankTransferWorker.pas',
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
