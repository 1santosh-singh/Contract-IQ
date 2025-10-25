import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  const body = await request.json();
  const authHeader = request.headers.get('Authorization');

  const response = await fetch('http://localhost:8000/api/query', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': authHeader || '',
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error('Backend query error:', errorText);
    return NextResponse.json({ detail: errorText }, { status: response.status });
  }

  const data = await response.json();
  return NextResponse.json(data, { status: response.status });
}