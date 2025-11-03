program DelphiMultithreadingBook1003;

uses
  Vcl.Forms,
  DelphiMultithreadingBook1003.MainForm in 'DelphiMultithreadingBook1003.MainForm.pas' {MainForm},
  DelphiMultithreadingBook.Utils in '..\Common\DelphiMultithreadingBook.Utils.pas',
  DelphiMultithreadingBook1003.FractalCalculator in 'DelphiMultithreadingBook1003.FractalCalculator.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
