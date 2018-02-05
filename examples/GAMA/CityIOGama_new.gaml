/**
* Name: CityIOGAMA
* Author: Arnaud Grignard
* Description: This is a template for the CityIO read/write in GAMA 1.7. 
* Tags: grid, load_file, json
*/

model CityIOGAMA

global {
	
	geometry shape <- square(1 #km);
	string cityIOurl <-"https://cityio.media.mit.edu/api/table/citymatrix_template";
    map<string, unknown> matrixData;
    map<int,rgb> buildingColors <-[-2::#red, -1::#orange,0::rgb(189,183,107), 1::rgb(189,183,107), 2::rgb(189,183,107),3::rgb(230,230,230), 4::rgb(230,230,230), 5::rgb(230,230,230),6::rgb(40,40,40),7::#cyan,8::#green,9::#gray];
    list<list<float>> cells;
    map<string, unknown> objects;
	int refresh <- 100 min: 1 max:1000 parameter: "Refresh rate (cycle):" category: "Grid";
	int matrix_size <- 16;
	
	init {
        do initGrid;
	}
	
	action initGrid{
		matrixData <- json_file(cityIOurl).contents;
		cells <- matrixData["grid"];
		objects <- matrixData["objects"];
		loop c over: cells {
			int x <- int(c[0]);
			int y <- int(c[1]);
            cityMatrix cell <- cityMatrix grid_at { x, y };
            cell.type <- int(c[3]);
            cell.depth<-int(c[4]);
        }  
        //save(json_file("https://cityio.media.mit.edu/api/table/update/cityIO_Gama", matrixData));
	}
	
	reflex updateGrid when: ((cycle mod refresh) = 0){
		do initGrid;
	}
}

grid cityMatrix width:matrix_size height:matrix_size {
	int type;
	int depth;
    aspect base{
	  draw shape color:buildingColors[type] depth:depth;
	  draw string(type) color:#black border:#black at:{location.x,location.y,depth+1};		
	}
}

experiment Display  type: gui {
	output {	
		display cityMatrixView  type:opengl  background:#black {
			species cityMatrix aspect:base;
		}
	}
}
