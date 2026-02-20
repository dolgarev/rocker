package Engine is

   Max_Rows : constant := 22;
   Max_Cols : constant := 80;

   type Entity_Type is (Space, Wall, Dirt, Player, Boulder, Diamond, Falling_Boulder, Falling_Diamond, Exit_Open, Exit_Closed);

   type Map_Data is array (1 .. Max_Rows, 1 .. Max_Cols) of Entity_Type;

   type Game_State is record
      Map             : Map_Data;
      Player_Row      : Integer;
      Player_Col      : Integer;
      Diamonds_Needed : Integer;
      Diamonds_Held   : Integer;
      Score           : Integer;
      Lives           : Integer;
      Tick_Count      : Integer;
      Death_Timer     : Integer;
      Game_Over       : Boolean;
      Level_Complete  : Boolean;
   end record;

   procedure Initialize (State : out Game_State);
   
   procedure Move_Player (State : in out Game_State; DR, DC : Integer);
   
   procedure Update_Physics (State : in out Game_State);

end Engine;
