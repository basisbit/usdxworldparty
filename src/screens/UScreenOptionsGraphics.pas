{*
    UltraStar Deluxe WorldParty - Karaoke Game

	UltraStar Deluxe WorldParty is the legal property of its developers,
	whose names	are too numerous to list here. Please refer to the
	COPYRIGHT file distributed with this source distribution.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program. Check "LICENSE" file. If not, see
	<http://www.gnu.org/licenses/>.
 *}


unit UScreenOptionsGraphics;

interface

{$MODE OBJFPC}

{$I switches.inc}

uses
  UMenu,
  sdl2,
  UDisplay,
  UMusic,
  UFiles,
  UIni,
  UThemes;

type
  TScreenOptionsGraphics = class(TMenu)
    private
      SelectWindowMode:    cardinal;
      SelectResolution:    cardinal;

      IResolutionEmpty:    array of UTF8String;
      ResolutionEmpty:     integer; // not used, only to prevent changing original by-ref passed variable

      OldWindowMode:       integer;

      procedure UpdateWindowMode;
      procedure UpdateResolution;

    public
      constructor Create; override;
      function ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean; override;
      procedure OnShow; override;
      procedure OnHide; override;
      procedure OnWindowResized; override;
  end;

implementation

uses
  UGraphic,
  UUnicodeUtils,
  SysUtils;

function TScreenOptionsGraphics.ParseInput(PressedKey: cardinal; CharCode: UCS4Char; PressedDown: boolean): boolean;
begin
  Result := true;
  if (PressedDown) then
  begin // Key Down
    // check normal keys
    case UCS4UpperCase(CharCode) of
      Ord('Q'):
        begin
          Result := false;
          Exit;
        end;
    end;

    // check special keys
    case PressedKey of
      SDLK_ESCAPE,
      SDLK_BACKSPACE :
        begin
          UIni.Ini.Save;
          AudioPlayback.PlaySound(SoundLib.Back);
          FadeTo(@ScreenOptions);
        end;
      SDLK_RETURN:
        begin
          if SelInteraction = 6 then
          begin
            UIni.Ini.Save;
            AudioPlayback.PlaySound(SoundLib.Back);

            if OldWindowMode <> UIni.Ini.FullScreen then UGraphic.UpdateVideoMode()
            else UGraphic.UpdateResolution();

            FadeTo(@ScreenOptions);
          end;
        end;
      SDLK_DOWN:
        InteractNext;
      SDLK_UP :
        InteractPrev;
      SDLK_RIGHT:
        begin
          if (SelInteraction >= 0) and (SelInteraction < 7) then
          begin
            AudioPlayback.PlaySound(SoundLib.Option);
            InteractInc;
          end;

          if (Interaction = SelectWindowMode) then
          begin
            UpdateResolution;
          end;

        end;
      SDLK_LEFT:
        begin
          if (SelInteraction >= 0) and (SelInteraction < 7) then
          begin
            AudioPlayback.PlaySound(SoundLib.Option);
            InteractDec;
          end;

          if (Interaction = SelectWindowMode) then
          begin
            UpdateResolution;
          end;
        end;
    end;
  end;
end;

constructor TScreenOptionsGraphics.Create;
begin
  inherited Create;
  LoadFromTheme(Theme.OptionsGraphics);

  ResolutionEmpty := 0;
  SetLength(IResolutionEmpty, 1);
  IResolutionEmpty[0] := '---';

  Theme.OptionsGraphics.SelectFullscreen.showArrows := true;
  Theme.OptionsGraphics.SelectFullscreen.oneItemOnly := true;
  SelectWindowMode := AddSelectSlide(Theme.OptionsGraphics.SelectFullscreen, UIni.Ini.Fullscreen, UIni.IFullScreen, 'OPTION_VALUE_');

  Theme.OptionsGraphics.SelectResolution.showArrows := true;
  Theme.OptionsGraphics.SelectResolution.oneItemOnly := true;
  SelectResolution := AddSelectSlide(Theme.OptionsGraphics.SelectResolution, UIni.Ini.Resolution, UIni.IResolution);

  //SelectLoadAnimation Hidden because it is useless atm
  //AddSelect(Theme.OptionsGraphics.SelectLoadAnimation, UIni.Ini.LoadAnimation, UIni.Ini.ILoadAnimation);
  Theme.OptionsGraphics.SelectScreenFade.showArrows := true;
  Theme.OptionsGraphics.SelectScreenFade.oneItemOnly := true;
  AddSelectSlide(Theme.OptionsGraphics.SelectScreenFade, UIni.Ini.ScreenFade, UIni.IScreenFade, 'OPTION_VALUE_');

  Theme.OptionsGraphics.SelectEffectSing.showArrows := true;
  Theme.OptionsGraphics.SelectEffectSing.oneItemOnly := true;
  AddSelectSlide(Theme.OptionsGraphics.SelectEffectSing, UIni.Ini.EffectSing, UIni.IEffectSing, 'OPTION_VALUE_');

  Theme.OptionsGraphics.SelectVisualizer.showArrows := true;
  Theme.OptionsGraphics.SelectVisualizer.oneItemOnly := true;
  AddSelectSlide(Theme.OptionsGraphics.SelectVisualizer, UIni.Ini.VisualizerOption, UIni.IVisualizer, 'OPTION_VALUE_');

  Theme.OptionsGraphics.SelectMovieSize.showArrows := true;
  Theme.OptionsGraphics.SelectMovieSize.oneItemOnly := true;
  AddSelectSlide(Theme.OptionsGraphics.SelectMovieSize, UIni.Ini.MovieSize, ['HALF', 'FULL_VID', 'FULL_VID_BG'], 'OPTION_VALUE_');

  // TODO: Add apply button
  AddButton(Theme.OptionsGraphics.ButtonExit);
  if (Length(Button[0].Text)=0) then
    AddButtonText(20, 6, Theme.Options.Description[OPTIONS_DESC_INDEX_BACK]);

end;

procedure TScreenOptionsGraphics.OnShow;
begin
  inherited;

  if CurrentWindowMode = Mode_Windowed then
    UIni.Ini.SetResolution(ScreenW, ScreenH);

  UpdateWindowMode();
  UpdateResolution();
  Interaction := 0;
end;

procedure TScreenOptionsGraphics.OnHide;
begin
  inherited;
  UIni.Ini.ClearCustomResolutions();
end;

procedure TScreenOptionsGraphics.OnWindowResized;
begin
  inherited;
  UpdateWindowMode;
  if CurrentWindowMode = Mode_Windowed then
    UIni.Ini.SetResolution(ScreenW, ScreenH);

  UpdateResolution;
end;

procedure TScreenOptionsGraphics.UpdateWindowMode;
begin
  UpdateSelectSlideOptions(Theme.OptionsGraphics.SelectFullscreen, SelectWindowMode, UIni.IFullScreen, UIni.Ini.FullScreen, 'OPTION_VALUE_');
  OldWindowMode := integer(UIni.Ini.FullScreen);
end;

procedure TScreenOptionsGraphics.UpdateResolution;
begin
  if UIni.Ini.Fullscreen = 2 then
    UpdateSelectSlideOptions(Theme.OptionsGraphics.SelectResolution, SelectResolution, IResolutionEmpty, ResolutionEmpty)
  else if UIni.Ini.Fullscreen = 1 then
    UpdateSelectSlideOptions(Theme.OptionsGraphics.SelectResolution, SelectResolution, UIni.IResolutionFullScreen, UIni.Ini.ResolutionFullscreen)
  else
    UpdateSelectSlideOptions(Theme.OptionsGraphics.SelectResolution, SelectResolution, UIni.IResolution, UIni.Ini.Resolution);
end;

end.
