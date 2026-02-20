with Engine; use Engine;
with Terminal_Interface.Curses; use Terminal_Interface.Curses;

package Renderer is

   procedure Initialize_Colors;
   
   procedure Show_Splash_Screen;
   procedure Center_Text (Win : Window; Row : Line_Position; Text : String);
   procedure Draw_Game (State : Game_State);
   
   procedure Show_Game_Over (State : Game_State);
   
   procedure Show_Level_Complete (State : Game_State);

end Renderer;
