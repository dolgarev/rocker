with Engine; use Engine;
with Renderer; use Renderer;
with Levels; use Levels;
with Terminal_Interface.Curses; use Terminal_Interface.Curses;

procedure Main is
   State   : Game_State;
   Key     : Key_Code;
   Win               : Window;
   Cur_Vis           : Cursor_Visibility := Invisible;
   Restart_Requested : Boolean;
begin
   -- Setup ncurses
   Init_Screen;
   Win := Standard_Window;
   Initialize_Colors;
   Set_Echo_Mode (False);
   Set_KeyPad_Mode (Win, True);
   Set_Cursor_Visibility (Cur_Vis);

   -- Splash Screen
   Renderer.Show_Splash_Screen;
   Set_Timeout_Mode (Win, Blocking, 0);
   Key := Get_Keystroke (Win);

   Game_Loop:
   loop
      -- Start a new game / level
      Restart_Requested := False;
      Levels.Setup_Level (State, 1);
      Set_Timeout_Mode (Win, Non_Blocking, 100); -- 100ms delay for loop

      Play_Session:
      loop
         Renderer.Draw_Game (State);
         
         Key := Get_Keystroke (Win);
         
         case Key is
            when Key_Cursor_Up    => Engine.Move_Player (State, -1, 0);
            when Key_Cursor_Down  => Engine.Move_Player (State, 1, 0);
            when Key_Cursor_Left  => Engine.Move_Player (State, 0, -1);
            when Key_Cursor_Right => Engine.Move_Player (State, 0, 1);
            when Character'Pos ('r') | Character'Pos ('R') =>
               Restart_Requested := True;
               exit Play_Session;
            when Character'Pos ('q') | Character'Pos ('Q') => exit Game_Loop;
            when others => null;
         end case;

         Engine.Update_Physics (State);

         exit Play_Session when State.Game_Over or State.Level_Complete;
      end loop Play_Session;

      if not Restart_Requested then
         -- Show result screen
         Set_Timeout_Mode (Win, Blocking, 0);
         if State.Game_Over then
            Renderer.Show_Game_Over (State);
         else
            Renderer.Show_Level_Complete (State);
         end if;

         -- Wait for Restart or Quit
         Wait_Input:
         loop
            Key := Get_Keystroke (Win);
            case Key is
               when Character'Pos ('r') | Character'Pos ('R') =>
                  exit Wait_Input; -- Restart game
               when Character'Pos ('q') | Character'Pos ('Q') =>
                  exit Game_Loop;   -- Quit program
               when others => null;
            end case;
         end loop Wait_Input;
      end if;

   end loop Game_Loop;

   -- Final cleanup
   End_Screen;
end Main;
