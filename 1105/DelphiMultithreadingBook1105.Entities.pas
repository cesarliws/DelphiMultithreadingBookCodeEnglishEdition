unit DelphiMultithreadingBook1105.Entities;

interface

uses
  System.Generics.Collections, System.SysUtils;

type
  TCustomerList = class;
  TOrderList = class;

  TOrder = class
  private
    FCustomerID: string;
    FEmployeeID: Integer;
    FFreight: Currency;
    FOrderDate: TDateTime;
    FOrderID: Integer;
    FRequiredDate: TDateTime;
    FShipAddress: string;
    FShipCity: string;
    FShipCountry: string;
    FShipName: string;
    FShippedDate: TDateTime;
    FShipPostalCode: string;
    FShipRegion: string;
    FShipVia: Integer;
  public
    procedure Assign(const Source: TOrder);
    property OrderID: Integer read FOrderID write FOrderID;
    property CustomerID: string read FCustomerID write FCustomerID;
    property EmployeeID: Integer read FEmployeeID write FEmployeeID;
    property OrderDate: TDateTime read FOrderDate write FOrderDate;
    property RequiredDate: TDateTime read FRequiredDate write FRequiredDate;
    property ShippedDate: TDateTime read FShippedDate write FShippedDate;
    property ShipVia: Integer read FShipVia write FShipVia;
    property Freight: Currency read FFreight write FFreight;
    property ShipName: string read FShipName write FShipName;
    property ShipAddress: string read FShipAddress write FShipAddress;
    property ShipCity: string read FShipCity write FShipCity;
    property ShipRegion: string read FShipRegion write FShipRegion;
    property ShipPostalCode: string read FShipPostalCode write FShipPostalCode;
    property ShipCountry: string read FShipCountry write FShipCountry;
  end;

  TCustomer = class
  private
    FAddress: string;
    FCity: string;
    FCompanyName: string;
    FContactName: string;
    FContactTitle: string;
    FCountry: string;
    FCustomerID: string;
    FFax: string;
    FOrders: TOrderList;
    FPhone: string;
    FPostalCode: string;
    FRegion: string;
    function GetOrders: TOrderList;
  public
    destructor Destroy; override;

    property CustomerID: string read FCustomerID write FCustomerID;
    property CompanyName: string read FCompanyName write FCompanyName;
    property ContactName: string read FContactName write FContactName;
    property ContactTitle: string read FContactTitle write FContactTitle;
    property Address: string read FAddress write FAddress;
    property City: string read FCity write FCity;
    property Region: string read FRegion write FRegion;
    property PostalCode: string read FPostalCode write FPostalCode;
    property Country: string read FCountry write FCountry;
    property Phone: string read FPhone write FPhone;
    property Fax: string read FFax write FFax;
    property Orders: TOrderList read GetOrders;

    procedure Assign(const Source: TCustomer);
    procedure ClearOrders;
    procedure AddOrder(Order: TOrder);
  end;

  TCustomerList = class(TObjectList<TCustomer>);
  TOrderList = class(TObjectList<TOrder>);

implementation

{ TCustomer }

destructor TCustomer.Destroy;
begin
  FOrders.Free;
  inherited;
end;

function TCustomer.GetOrders: TOrderList;
begin
  if not Assigned(FOrders) then
    FOrders := TOrderList.Create(True);
  Result := FOrders;
end;

procedure TCustomer.Assign(const Source: TCustomer);
begin
  Self.CompanyName := Source.CompanyName;
  Self.ContactName := Source.ContactName;
  Self.ContactTitle := Source.ContactTitle;
  Self.Address := Source.Address;
  Self.City := Source.City;
  Self.Region := Source.Region;
  Self.PostalCode := Source.PostalCode;
  Self.Country := Source.Country;
  Self.Phone := Source.Phone;
  Self.Fax := Source.Fax;
end;

procedure TCustomer.ClearOrders;
begin
  if Assigned(FOrders) then
    FOrders.Clear;
end;

procedure TCustomer.AddOrder(Order: TOrder);
begin
  Orders.Add(Order);
end;

{ TOrder }

procedure TOrder.Assign(const Source: TOrder);
begin
  Self.CustomerID := Source.CustomerID;
  Self.EmployeeID := Source.EmployeeID;
  Self.OrderDate := Source.OrderDate;
  Self.RequiredDate := Source.RequiredDate;
  Self.ShippedDate := Source.ShippedDate;
  Self.ShipVia := Source.ShipVia;
  Self.Freight := Source.Freight;
  Self.ShipName := Source.ShipName;
  Self.ShipAddress := Source.ShipAddress;
  Self.ShipCity := Source.ShipCity;
  Self.ShipRegion := Source.ShipRegion;
  Self.ShipPostalCode := Source.ShipPostalCode;
  Self.ShipCountry := Source.ShipCountry;
end;

end.
