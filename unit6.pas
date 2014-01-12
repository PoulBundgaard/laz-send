unit Unit6;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, DBGrids;
Const
   ListaPol : array[1..24,1..2] of string = (
{ 1}   ('Miasto (praca)',            'miasto_pra'),
{ 2}   ('Firma/Organizacja',         'firma_Org'),
{ 3}   ('Telefon domowy',            'tel_dom'),
{ 4-}  ('Podstawowy e-mail',         'podstemail'),
{ 5}   ('Wyświetlana nazwa',         'wysw_nazwa'),
{ 6}   ('Telefonu służbowy',         'tel_sluzbo'),
{ 7}   ('Adres domowy',              'adr_dom'),
{ 8}   ('Województwo (dom)',         'wojew_dom'),
{ 9}   ('Państwo (dom)',             'panst_dom'),
{10}   ('Kod pocztowy (dom)',        'kod_pocztd'),
{11}   ('Imię',                      'imie'),
{12}   ('Numer telefonu komórkowego','tel_kom'),
{13}   ('Numer faksu',               'nr_faksu'),
{14}   ('Nazwisko',                  'nazwisko'),
{15-}  ('Dodatkowy e-mail',          'dodatemail'),
{16}   ('Stanowisko',                'stanowisko'),
{17}   ('Firmowa strona WWW',        'fstrwww'),
{18}   ('Kod pocztowy (praca)',      'kod_pocztp'),
{19}   ('Województwo (praca)',       'wojew_prac'),
{20}   ('Adres służbowy',            'adr_sluzb'),
{21}   ('Pseudonim',                 'pseudonim'),
{22}   ('Miasto (dom)',              'miasto_dom'),
{23}   ('Strona WWW',                'stronaWWW'),
{24}   ('Państwo (paraca)',          'panst_prac'));

var
  exe_path : string;

   procedure SaveFormState(name : string; var aForm : TForm);
   procedure LoadFormState(name : string; var aForm : TForm);

   procedure SaveDBGridState(name : string; var aGrid : TDBGrid);
   procedure LoadDBGridState(name : string; var aGrid : TDBGrid);

implementation

Type
  TFormState = record
    left, top: integer;
    height, width : integer;
  end;
  TFormStateFile = file of TFormState;

  TDBGridState = record
    FieldName : string[80];
    Caption   : string[80];
    width     : integer;
  end;
  TDBGridStateFile = file of TDBGridState;

procedure SaveFormState(name: string; var aForm: TForm);
var
  f   : TFormStateFile;
  b   : TFormState;
begin
  AssignFile(f,exe_path+'form_'+name);
  rewrite(f);
  b.left  :=aForm.Left;
  b.top   :=aForm.Top;
  b.height:=aForm.Height;
  b.width :=aForm.Width;
  write(f,b);
  CloseFile(f);
end;

procedure LoadFormState(name: string; var aForm: TForm);
var
  f   : TFormStateFile;
  b   : TFormState;
begin
  if not FileExists(exe_path+'form_'+name) then exit;

  AssignFile(f,exe_path+'form_'+name);
  reset(f);
  read(f,b);
  closefile(f);

  aForm.Left  :=b.left;
  aForm.Top   :=b.top;
  aForm.Height:=b.height;
  aForm.Width :=b.width;

end;

procedure LoadDBGridState(name : string; var aGrid : TDBGrid);
var
  i : integer;
  r : TDBGridState;
  f : TDBGridStateFile;
begin
  if fileexists(exe_path+'dbgrid_'+name) then
  begin
    assignfile(f,exe_path+'dbgrid_'+name);
    reset(f);
    for i:=0 to aGrid.Columns.Count-1 do
    begin
      read(f,r);
      aGrid.Columns.Items[i].FieldName    :=r.FieldName;
      aGrid.Columns.Items[i].Title.Caption:=r.Caption;
      aGrid.Columns.Items[i].Width        :=r.Width;
    end;
    closefile(f);
  end;
end;

procedure SaveDBGridState(name : string; var aGrid : TDBGrid);
var
  i : integer;
  r : TDBGridState;
  f : TDBGridStateFile;
begin
  assignfile(f,exe_path+'dbgrid_'+name);
  rewrite(f);
  for i:=0 to aGrid.Columns.Count-1 do
  begin
    r.FieldName:=aGrid.Columns.Items[i].FieldName;
    r.Caption  :=aGrid.Columns.Items[i].Title.Caption;
    r.Width    :=aGrid.Columns.Items[i].Width;
    write(f,r);
  end;
  closefile(f);
end;

initialization
  exe_path:=ExtractFilePath(paramstr(0));
  if exe_path[length(exe_path)] <> '\' then exe_path:=exe_path+'\';
end.

