program DelphiMultithreadingBook0602;

uses
  Vcl.Forms,
  DelphiMultithreadingBook0602.MainForm in 'DelphiMultithreadingBook0602.MainForm.pas' {MainForm},
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
