unit DelphiMultithreadingBook1105.CustomerView;

interface

uses
  System.Classes, System.SysUtils, System.Variants, Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ComCtrls, Vcl.ExtCtrls,
  DelphiMultithreadingBook1105.Entities, DelphiMultithreadingBook1105.Interfaces;

type
  TCustomerForm = class(TForm, ICustomerCallbacks)
    ButtonsPanel: TPanel;
    SaveButton: TButton;
    CancelButton: TButton;
    ControlsPanel: TPanel;
    CustomerInfoGroupBox: TGroupBox;
    CustomerIDLabel: TLabel;
    CustomerIDEdit: TEdit;
    CompanyNameLabel: TLabel;
    CompanyNameEdit: TEdit;
    ContactNameLabel: TLabel;
    ContactNameEdit: TEdit;
    ContactTitleLabel: TLabel;
    ContactTitleEdit: TEdit;
    AddressLabel: TLabel;
    AddressEdit: TEdit;
    CityLabel: TLabel;
    CityEdit: TEdit;
    RegionLabel: TLabel;
    RegionEdit: TEdit;
    PostalCodeLabel: TLabel;
    PostalCodeEdit: TEdit;
    CountryLabel: TLabel;
    CountryEdit: TEdit;
    PhoneLabel: TLabel;
    PhoneEdit: TEdit;
    FaxLabel: TLabel;
    FaxEdit: TEdit;
    procedure SaveButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FController: IController;
    FCustomer: TCustomer;
    FIsNewCustomer: Boolean;
    procedure SetControlsState(IsRunning: Boolean);
    procedure LoadCustomerData;
    procedure SaveCustomerData;
    // ICustomerCallbacks
    procedure OnCustomersLoaded(Customers: TCustomerList);
    procedure OnCustomerSaved(Customer: TCustomer);
    procedure OnCustomerDeleted(CustomerID: string);
    procedure OnError(const ErrorMessage: string);
  public
    class function CreateNewCustomer(Controller: IController): TCustomer; static;
    class function EditCustomer(Customer: TCustomer; Controller: IController): Boolean; static;
  end;

var
  CustomerForm: TCustomerForm;

implementation

{$R *.dfm}

uses
  System.StrUtils, DelphiMultithreadingBook.Utils;

{ TCustomerForm }

class function TCustomerForm.CreateNewCustomer(Controller: IController): TCustomer;
begin
  Result := nil;
  var Form := TCustomerForm.Create(Application);
  try
    Form.FController := Controller;
    Form.FIsNewCustomer := True;
    // Create new customer
    var Customer := TCustomer.Create;
    Form.FCustomer := Customer;
    Form.LoadCustomerData;
    if Form.ShowModal = mrOk then
      Result := Form.FCustomer
    else if Assigned(Form.FCustomer) then
      Form.FCustomer.Free;
  finally
    Form.Free;
  end;
end;

class function TCustomerForm.EditCustomer(Customer: TCustomer; Controller: IController): Boolean;
begin
  Result := False;
  var Form := TCustomerForm.Create(Application);
  try
    Form.FController := Controller;
    Form.FCustomer := Customer;
    Form.FIsNewCustomer := False;
    Form.LoadCustomerData;
    if Form.ShowModal = mrOk then
      Result := True;
  finally
    Form.Free;
  end;
end;

procedure TCustomerForm.LoadCustomerData;
begin
  if FIsNewCustomer then
  begin
    // New customer - editable fields
    CustomerIDEdit.ReadOnly := False;
    CustomerIDEdit.Text := '';
    Caption := 'New Customer';
  end
  else
  begin
    // Editing - ID not editable
    CustomerIDEdit.ReadOnly := True;
    CustomerIDEdit.Text := FCustomer.CustomerID;
    Caption := 'Edit Customer - ' + FCustomer.CustomerID;
  end;
  // Fill the fields
  CompanyNameEdit.Text := FCustomer.CompanyName;
  ContactNameEdit.Text := FCustomer.ContactName;
  ContactTitleEdit.Text := FCustomer.ContactTitle;
  AddressEdit.Text := FCustomer.Address;
  CityEdit.Text := FCustomer.City;
  RegionEdit.Text := FCustomer.Region;
  PostalCodeEdit.Text := FCustomer.PostalCode;
  CountryEdit.Text := FCustomer.Country;
  PhoneEdit.Text := FCustomer.Phone;
  FaxEdit.Text := FCustomer.Fax;
end;

procedure TCustomerForm.SaveCustomerData;
begin
  if FIsNewCustomer then
    FCustomer.CustomerID := CustomerIDEdit.Text;
  FCustomer.CompanyName := CompanyNameEdit.Text;
  FCustomer.ContactName := ContactNameEdit.Text;
  FCustomer.ContactTitle := ContactTitleEdit.Text;
  FCustomer.Address := AddressEdit.Text;
  FCustomer.City := CityEdit.Text;
  FCustomer.Region := RegionEdit.Text;
  FCustomer.PostalCode := PostalCodeEdit.Text;
  FCustomer.Country := CountryEdit.Text;
  FCustomer.Phone := PhoneEdit.Text;
  FCustomer.Fax := FaxEdit.Text;
end;

procedure TCustomerForm.SaveButtonClick(Sender: TObject);
begin
  SaveCustomerData;
  if not FController.ValidateCustomer(FCustomer) then
  begin
    ShowMessage('Invalid customer, please check the information.');
    Exit;
  end;
  SetControlsState(True);
  FController.SaveCustomer(FCustomer, Self);
end;

procedure TCustomerForm.CancelButtonClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TCustomerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult <> mrOk then
  begin
    if FIsNewCustomer and Assigned(FCustomer) then
    begin
      FCustomer.Free;
      FCustomer := nil;
    end;
  end;
end;

procedure TCustomerForm.SetControlsState(IsRunning: Boolean);
begin
  SaveButton.Enabled := not IsRunning;
  CancelButton.Enabled := not IsRunning;
  ControlsPanel.Enabled := not IsRunning;
end;

{ ICustomerCallbacks }

procedure TCustomerForm.OnCustomersLoaded(Customers: TCustomerList);
begin
  // Not used in this form
end;

procedure TCustomerForm.OnCustomerSaved(Customer: TCustomer);
begin
  TThread.Queue(nil,
    procedure
    begin
      if FIsNewCustomer then
        ShowMessage('Customer created successfully! ID: ' + Customer.CustomerID)
      else
        ShowMessage('Customer updated successfully!');
      ModalResult := mrOk;
    end);
end;

procedure TCustomerForm.OnCustomerDeleted(CustomerID: string);
begin
  // Not used in this form
end;

procedure TCustomerForm.OnError(const ErrorMessage: string);
begin
  TThread.Queue(nil,
    procedure
    begin
      ShowMessage('Error: ' + ErrorMessage);
      SetControlsState(False);
    end);
end;

end.
