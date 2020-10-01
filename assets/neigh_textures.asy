settings.outformat = "pdf";
settings.render = 8;
unitsize(15);

void Texture(string[] values, real width, real height, pair pos) {
    int N = values.length;
    fill(box((width*(N/2.0-1.0), height*0.5) + pos, (width*(N/2.0), -height*0.5) + pos), lightgrey);

    draw((-width*0.5, height*0.5) + pos -- (width*(N - 0.5), height*0.5) + pos);
	draw((-width*0.5, -height*0.5) + pos -- (width*(N - 0.5), -height*0.5) + pos);
	for (int i = 0; i < N; ++i)
	{
		draw((width*(-0.5 + i), height*0.5) + pos -- (width*(-0.5 + i), -height*0.5) + pos);
		label("\texttt{"+values[i]+"}", position=((width*i, 0) + pos));
	}
	draw((width*(N - 0.5), height*0.5) + pos -- (width*(N - 0.5), -height*0.5) + pos);

	draw((width*(N - 0.5), height*0.5) + pos -- (width*(N+0.2), height*0.5) + pos -- (width*(N - 0.2), -height*0.5) + pos -- (width*(N - 0.5), -height*0.5) + pos);
    draw((width*( - 0.5), height*0.5) + pos -- (width*(-0.7), height*0.5) + pos -- (width*(-1.2), -height*0.5) + pos -- (width*(- 0.5), -height*0.5) + pos);
}

string l[] = {"61", "62", "63", "64", "65", "66", "67"};
int N = l.length;
for (int i = 0; i < N; ++i)
{
    label("\texttt{"+l[i]+"}", position=((1.6*i, 0)));
    draw((1.6*i, -0.5) -- (1.6*i, - 1.1), arrow=Arrow());
}

string l[] = {"4", "61", "62", "63", "64", "65", "0"};
Texture(l, 1.6, 1.6, (0, -2.0));

string l[] = {"75", "557", "556", "555", "554", "553", "40"};
Texture(l, 1.6, 1.6, (0, -4.0));

string l[] = {"557", "556", "555", "554", "553", "552", "552"};
Texture(l, 1.6, 1.6, (0, -6.0));

string l[] = {"62", "63", "64", "65", "66", "67", "66"};
Texture(l, 1.6, 1.6, (0, -8.0));

string l[] = {"558", "559", "561", "564", "568", "573", "573"};
Texture(l, 1.6, 1.6, (0, -10.0));

string l[] = {"74", "558", "559", "561", "564", "568", "53"};
Texture(l, 1.6, 1.6, (0, -12.0));

string l[] = {".", ".", ".", ".", ".", ".", "."};
Texture(l, 1.6, 1.6, (0, -15.0));

label(Label("vertex index", position=(-2.5, 0.0), align=W));
label(Label("\texttt{n1}", position=(-2.5, -2.0), align=W));
label(Label("\texttt{n2}", position=(-2.5, -4.0), align=W));
label(Label("\texttt{n3}", position=(-2.5, -6.0), align=W));
label(Label("\texttt{n4}", position=(-2.5, -8.0), align=W));
label(Label("\texttt{n5}", position=(-2.5, -10.0), align=W));
label(Label("\texttt{n6}", position=(-2.5, -12.0), align=W));
label(Label("vertex position", position=(-2.5, -15.0), align=W));