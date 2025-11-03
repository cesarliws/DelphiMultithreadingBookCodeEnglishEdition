unit DelphiMultithreadingBook0908.MainForm;

interface

uses
  FMX.Controls, FMX.Controls.Presentation, FMX.Forms, FMX.Graphics, FMX.ImgList, FMX.Layouts,
  FMX.ListView, FMX.ListView.Adapters.Base, FMX.ListView.Appearances, FMX.ListView.Types,
  FMX.Memo, FMX.Memo.Types, FMX.ScrollBox, FMX.StdCtrls, FMX.Types, System.Classes,
  System.ImageList, System.Permissions, System.Threading, System.Types,
  DelphiMultithreadingBook.CancellationToken, DelphiMultithreadingBook0908.ImageProcessor;

type
  TMainForm = class(TForm)
    CancelButton: TButton;
    TopLayout: TLayout;
    LogMemo: TMemo;
    StartButton: TButton;
    ProgressBar: TProgressBar;
    BottomLayout: TLayout;
    DeleteOutputButton: TButton;
    SaveFilesCheckBox: TCheckBox;
    procedure DeleteOutputButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
  private
    FCurrentTask: ITask;
    FCancellationTokenSource: TCancellationTokenSource;
    FImageProcessor: TImageProcessor;
    FOutputPath: string;
    FPicturesPath: string;
    FProcessedCount: Integer;
    FTotalCount: Integer;
    function HasOutputFiles: Boolean;
    procedure ConfigurePath;
    procedure StartProcessing;
    procedure ProcessingProgress;
    procedure ProcessingComplete(const Cancelled: Boolean; const ElapsedMs: Int64);
    procedure RequestPermissionsResult(Sender: TObject; const Permissions: TClassicStringDynArray;
      const GrantResults: TClassicPermissionStatusDynArray);
    procedure SetControlsState(IsRunning: Boolean);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  FMX.DialogService, FMX.MultiResBitmap, System.IOUtils, System.SysUtils, System.UITypes,
  DelphiMultithreadingBook.Utils;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterLogger(LogMemo.Lines);
  LogMemo.WordWrap := True;
  ConfigurePath;
  SetControlsState(False);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  UnregisterLogger;
  if Assigned(FCancellationTokenSource) then
  begin
    FCancellationTokenSource.Cancel;
    FCancellationTokenSource.Free;
  end;

  if Assigned(FImageProcessor) then
    FImageProcessor.Free;
end;

function TMainForm.HasOutputFiles: Boolean;
begin
  Result := (FOutputPath <> '') and TDirectory.Exists(FOutputPath)
    and not TDirectory.IsEmpty(FOutputPath);
end;

procedure TMainForm.StartButtonClick(Sender: TObject);
begin
  SetControlsState(True);
  LogMemo.Lines.Clear;
  LogWrite('> Requesting storage read permission on the device.');
  TTask.Run(
    procedure
    begin
      PermissionsService.RequestPermissions([
        'android.permission.READ_EXTERNAL_STORAGE',
        'android.permission.READ_MEDIA_IMAGES'],
        RequestPermissionsResult);
    end);
end;

procedure TMainForm.CancelButtonClick(Sender: TObject);
begin
  if Assigned(FCancellationTokenSource) then
    FCancellationTokenSource.Cancel;
end;

procedure TMainForm.DeleteOutputButtonClick(Sender: TObject);
begin
  if HasOutputFiles then
  begin
    TDialogService.MessageDialog('Delete all created files?',
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbNo, TMsgDlgBtn.mbYes], TMsgDlgBtn.mbYes, 0,
      procedure(const AResult: TModalResult)
      begin
        if AResult = mrYes then
        begin
          TDirectory.Delete(FOutputPath, True);
          SetControlsState(False);
        end;
      end);
  end;
end;

procedure TMainForm.ConfigurePath;
begin
{$IFDEF MSWINDOWS}
  FPicturesPath := TPath.GetPicturesPath;
{$ELSE}
  FPicturesPath := TPath.GetSharedPicturesPath;
  BottomLayout.Visible := False;
{$ENDIF};
  FOutputPath := TPath.Combine(FPicturesPath, 'Filtered_Grayscale');
end;

procedure TMainForm.RequestPermissionsResult(Sender: TObject; const Permissions:
  TClassicStringDynArray; const GrantResults: TClassicPermissionStatusDynArray);
begin
  if (Length(GrantResults) > 0) and (GrantResults[0] = TPermissionStatus.Granted) then
  begin
    LogWrite('* Permission granted.');
    LogWrite('> Starting to read files...');
    StartProcessing;
  end
  else
  begin
    LogWrite('! Permission to read files was denied.');
    SetControlsState(False);
  end;
end;


procedure TMainForm.StartProcessing;
var
  ImagePaths: TStringDynArray;
  Token: ICancellationToken;
  OutputDirectory: string;
begin
  ImagePaths := TDirectory.GetFiles(FPicturesPath, '*.*',
    function(const Path: string; const SearchRec: TSearchRec): Boolean
    begin
      try
        Result := TPath.MatchesPattern(SearchRec.Name, '*.jpg', False);
      except
        on E: Exception do
        begin
          Result := False;
          LogWrite('ERROR: ' + E.ToString);
        end;
      end;
    end);

  if Length(ImagePaths) > 0 then
  begin
    SetControlsState(True);
    FProcessedCount := 0;
    FTotalCount := Length(ImagePaths);
    ProgressBar.Max := FTotalCount;
    LogWrite('%d jpg images found in %s.', [FTotalCount, QuotedStr(FPicturesPath)]);
    if SaveFilesCheckBox.IsChecked then
      OutputDirectory := FOutputPath
    else
      OutputDirectory := '';
{$IFNDEF ANDROID}
    if SaveFilesCheckBox.IsChecked and (not TDirectory.Exists(OutputDirectory)) then
      TDirectory.CreateDirectory(OutputDirectory);
{$ENDIF}
    if FCancellationTokenSource = nil then
      FCancellationTokenSource := TCancellationTokenSource.Create
    else
      FCancellationTokenSource.Reset;

    Token := FCancellationTokenSource.Token;
    LogWrite('Starting processing, UI will NOT be responsive.');
    FImageProcessor := TImageProcessor.Create;

    FCurrentTask := FImageProcessor.ProcessImagesAsync(ImagePaths,
      OutputDirectory, Token, ProcessingProgress, ProcessingComplete);
  end
  else
    LogWrite('No jpg images found in %s.', [QuotedStr(FPicturesPath)]);
end;

procedure TMainForm.ProcessingProgress;
begin
  if csDestroying in ComponentState then Exit;
  Inc(FProcessedCount);
  ProgressBar.Value := FProcessedCount;
  LogWrite(Format('%d of %d images processed...', [FProcessedCount, FTotalCount]));
  LogMemo.GoToTextEnd;
end;

procedure TMainForm.ProcessingComplete(const Cancelled: Boolean; const ElapsedMs: Int64);
begin
  if csDestroying in ComponentState then Exit;
  if Cancelled then
    LogWrite('Processing canceled.')
  else
    LogWrite(Format('Processing completed in %d ms.', [ElapsedMs]));
{$IFDEF MSWINDOWS}
  LogWrite('* Attention, the images are saved in %s!', [QuotedStr(FOutputPath)]);
{$ENDIF};
  FCurrentTask := nil;
  FImageProcessor.Free;
  FImageProcessor := nil;
  SetControlsState(False);
end;

procedure TMainForm.SetControlsState(IsRunning: Boolean);
begin
  StartButton.Enabled := not IsRunning;
  SaveFilesCheckBox.Enabled := not IsRunning;
  CancelButton.Enabled := IsRunning;
  CancelButton.Visible := IsRunning;
  DeleteOutputButton.Enabled := not IsRunning and HasOutputFiles;
  LogMemo.GoToTextEnd;
end;

end.
