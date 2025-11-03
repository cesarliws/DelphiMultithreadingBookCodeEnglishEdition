program DelphiMultithreadingBook1002;

uses
  Vcl.Forms,
  DelphiMultithreadingBook1002.MainForm in 'DelphiMultithreadingBook1002.MainForm.pas' {MainForm},
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas',
  DelphiMultithreadingBook.ApiDownloader in '..\Common\DelphiMultithreadingBook.ApiDownloader.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
