unit Unit3;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, dbf, FileUtil, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, Buttons, ComCtrls, DBGrids, unit6;

type

  { TForm3 }

  TForm3 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Datasource1: TDatasource;
    Datasource2: TDatasource;
    Dbf1: TDbf;
    Dbf2: TDbf;
    DBGrid1: TDBGrid;
    DBGrid2: TDBGrid;
    Edit1: TEdit;
    Label1: TLabel;
    Panel1: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    Panel9: TPanel;
    RadioGroup1: TRadioGroup;
    procedure BitBtn1Click(Sender: TObject);
    procedure Dbf1FilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure DBGrid2CellClick(Column: TColumn);
    procedure Edit1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    default_id_operat : integer;
    default_nm_operat : string;

    szukanie          : string;

    em_smtp  : string;
    em_port  : string;
    em_login : string;
    em_pass  : string;
    em_email : string;

  end;

var
  Form3: TForm3;

implementation
{$R *.lfm}

{ TForm3 }

procedure TForm3.FormShow(Sender: TObject);
var
  buf : string;
begin
  form3.Caption:='WanKom 0.1 ('+IntToStr(form3.default_id_operat)+') '+form3.default_nm_operat;

  buf:=ExtractFilePath(paramstr(0));
  if buf[length(buf)] <> '\' then buf:=buf+'\';

  if dbf1.Active then dbf1.Close;
  dbf1.FilePathFull:=buf;
  dbf1.TableName:='kontakty.dbf';
  dbf1.TableLevel:=7;
  dbf1.Open;

  if dbf2.Active then dbf2.Close;
  dbf2.FilePathFull:=buf;
  dbf2.TableName:='operator.dbf';
  dbf2.TableLevel:=7;
  dbf2.Open;

  LoadFormState('ksiazka',TForm(form3));
  LoadDBGridState('kontakty_form3', dbgrid1);
  LoadDBGridState('operator_form3', dbgrid2);
end;

procedure TForm3.Dbf1FilterRecord(DataSet: TDataSet; var Accept: Boolean);
begin
  case RadioGroup1.ItemIndex of
    0 : begin
          accept:= dataset.FieldByName('idoperat').AsInteger = form3.default_id_operat;
          if szukanie <> '' then
          begin
            accept:= accept and ( (Pos(UpperCase(edit1.Text), UpperCase(dataset.FieldByName(ListaPol[ 4,2]).AsString)) <> 0) or
                                  (Pos(UpperCase(edit1.Text), UpperCase(dataset.FieldByName(ListaPol[15,2]).AsString)) <> 0) or
                                  (Pos(UpperCase(edit1.Text), UpperCase(dataset.FieldByName(ListaPol[14,2]).AsString)) <> 0) or
                                  (Pos(UpperCase(edit1.Text), UpperCase(dataset.FieldByName(ListaPol[11,2]).AsString)) <> 0) or
                                  (Pos(UpperCase(edit1.Text), UpperCase(dataset.FieldByName(ListaPol[ 5,2]).AsString)) <> 0)
                                );
          end;
        end;
    1 : begin
          if trim(edit1.Text) <> '' then
          begin
            edit1.Text:=trim(edit1.Text);

            accept:=( (Pos(UpperCase(edit1.Text), UpperCase(dataset.FieldByName(ListaPol[ 4,2]).AsString)) <> 0) or
                      (Pos(UpperCase(edit1.Text), UpperCase(dataset.FieldByName(ListaPol[15,2]).AsString)) <> 0) or
                      (Pos(UpperCase(edit1.Text), UpperCase(dataset.FieldByName(ListaPol[14,2]).AsString)) <> 0) or
                      (Pos(UpperCase(edit1.Text), UpperCase(dataset.FieldByName(ListaPol[11,2]).AsString)) <> 0) or
                      (Pos(UpperCase(edit1.Text), UpperCase(dataset.FieldByName(ListaPol[ 5,2]).AsString)) <> 0)
                    );
          end
          else accept:=true;
        end;
    2 : begin
          accept:=dataset.FieldByName('idoperat').AsInteger = dbf2.FieldByName('id').AsInteger;
          if trim(edit1.Text) <> '' then
          begin
            edit1.Text:=trim(edit1.Text);
            accept:= accept and ( (Pos(UpperCase(edit1.Text), UpperCase(dataset.FieldByName(ListaPol[ 4,2]).AsString)) <> 0) or
                                  (Pos(UpperCase(edit1.Text), UpperCase(dataset.FieldByName(ListaPol[15,2]).AsString)) <> 0) or
                                  (Pos(UpperCase(edit1.Text), UpperCase(dataset.FieldByName(ListaPol[14,2]).AsString)) <> 0) or
                                  (Pos(UpperCase(edit1.Text), UpperCase(dataset.FieldByName(ListaPol[11,2]).AsString)) <> 0) or
                                  (Pos(UpperCase(edit1.Text), UpperCase(dataset.FieldByName(ListaPol[ 5,2]).AsString)) <> 0)
                                );
          end;
        end;
  end;
end;

procedure TForm3.DBGrid1DblClick(Sender: TObject);
begin
  bitbtn1.Click;    // uruchomienie klikniecia przycisku WYBIERZ
end;

procedure TForm3.BitBtn1Click(Sender: TObject);
begin

end;

procedure TForm3.DBGrid2CellClick(Column: TColumn);
begin
  dbf1.Filtered:=false;
  dbf1.Filtered:=true;
end;

// wpisywanie frazy - szukanie kontaku
procedure TForm3.Edit1Change(Sender: TObject);
begin
  if trim(edit1.Text) = '' then exit;
  szukanie:=edit1.Text;
{
1 : dbf1.Locate(ListaPol[15,2],edit1.Text,[loCaseInsensitive, loPartialKey]); // email dodatkowy
2 : dbf1.Locate(ListaPol[14,2],edit1.Text,[loCaseInsensitive, loPartialKey]); // nazwisko
3 : dbf1.Locate(ListaPol[11,2],edit1.Text,[loCaseInsensitive, loPartialKey]); // imie
4 : dbf1.Locate(ListaPol[ 5,2],edit1.Text,[loCaseInsensitive, loPartialKey]); // nazwa wyswietlana
}
  dbf1.Filtered:=false;
  dbf1.Filtered:=true;
end;

procedure TForm3.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  SaveFormState('ksiazka',TForm(form3));
  SaveDBGridState('kontakty_form3', dbgrid1);
  SaveDBGridState('operator_form3', dbgrid2);
end;

procedure TForm3.RadioGroup1Click(Sender: TObject);
begin
//  case RadioGroup1.ItemIndex of
//    0 : dbf1.Filtered:=true;
//    1 : dbf1.Filtered:=false;
//  end;
  dbf1.Filtered:=false;
  dbf1.Filtered:=true;
end;

end.

