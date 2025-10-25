-- Enable pgvector extension if not already enabled
-- Run this in Supabase SQL Editor: CREATE EXTENSION IF NOT EXISTS vector;

-- Create documents table
CREATE TABLE IF NOT EXISTS user_documents (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  file_name TEXT NOT NULL,
  file_type TEXT NOT NULL,
  storage_path TEXT, -- Path to file in Supabase storage bucket
  upload_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add storage_path column to existing table if it doesn't exist (for migration)
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                   WHERE table_name='user_documents' AND column_name='storage_path') THEN
        ALTER TABLE user_documents ADD COLUMN storage_path TEXT;
    END IF;
END $$;

-- Create chunks table
CREATE TABLE IF NOT EXISTS document_chunks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  document_id UUID NOT NULL REFERENCES user_documents(id) ON DELETE CASCADE,
  chunk_text TEXT NOT NULL,
  chunk_index INTEGER NOT NULL,
  embedding VECTOR(768),  -- LegalBERT (bert-base) hidden size
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for similarity search
CREATE INDEX IF NOT EXISTS chunks_embedding_idx ON document_chunks USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Row Level Security (RLS) policies
ALTER TABLE user_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_chunks ENABLE ROW LEVEL SECURITY;

-- Drop and recreate policies to make idempotent
DROP POLICY IF EXISTS "Users can view own documents" ON user_documents;
CREATE POLICY "Users can view own documents" ON user_documents
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own documents" ON user_documents;
CREATE POLICY "Users can insert own documents" ON user_documents
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can view own chunks" ON document_chunks;
CREATE POLICY "Users can view own chunks" ON document_chunks
  FOR SELECT USING (
    document_id IN (
      SELECT id FROM user_documents WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can insert own chunks" ON document_chunks;
CREATE POLICY "Users can insert own chunks" ON document_chunks
  FOR INSERT WITH CHECK (
    document_id IN (
      SELECT id FROM user_documents WHERE user_id = auth.uid()
    )
  );

-- Create match_documents function for RAG similarity search
CREATE OR REPLACE FUNCTION match_documents(
  query_embedding vector(768),
  match_threshold float,
  match_count int,
  document_id uuid
)
RETURNS TABLE (
  id uuid,
  chunk_text text,
  similarity float
)
LANGUAGE sql STABLE
AS $$
  SELECT
    dc.id,
    dc.chunk_text,
    1 - (dc.embedding <=> query_embedding) AS similarity
  FROM document_chunks dc
  WHERE
    dc.document_id = document_id
    AND dc.embedding IS NOT NULL
    AND 1 - (dc.embedding <=> query_embedding) > match_threshold
  ORDER BY dc.embedding <=> query_embedding
  LIMIT match_count;
$$;

-- Create document_summaries table
CREATE TABLE IF NOT EXISTS document_summaries (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  document_id UUID NOT NULL REFERENCES user_documents(id) ON DELETE CASCADE,
  summary TEXT NOT NULL,
  generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE document_summaries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own summaries" ON document_summaries;
CREATE POLICY "Users can view own summaries" ON document_summaries
  FOR SELECT USING (
    document_id IN (
      SELECT id FROM user_documents WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can insert own summaries" ON document_summaries;
CREATE POLICY "Users can insert own summaries" ON document_summaries
  FOR INSERT WITH CHECK (
    document_id IN (
      SELECT id FROM user_documents WHERE user_id = auth.uid()
    )
  );

-- Create document_risk_analyses table
CREATE TABLE IF NOT EXISTS document_risk_analyses (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  document_id UUID NOT NULL REFERENCES user_documents(id) ON DELETE CASCADE,
  analysis TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE document_risk_analyses ENABLE ROW LEVEL SECURITY;

-- Risk analyses policies
DROP POLICY IF EXISTS "Users can view own risk analyses" ON document_risk_analyses;
CREATE POLICY "Users can view own risk analyses" ON document_risk_analyses
  FOR SELECT USING (
    document_id IN (
      SELECT id FROM user_documents WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can insert own risk analyses" ON document_risk_analyses;
CREATE POLICY "Users can insert own risk analyses" ON document_risk_analyses
  FOR INSERT WITH CHECK (
    document_id IN (
      SELECT id FROM user_documents WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can update own risk analyses" ON document_risk_analyses;
CREATE POLICY "Users can update own risk analyses" ON document_risk_analyses
  FOR UPDATE USING (
    document_id IN (
      SELECT id FROM user_documents WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can delete own risk analyses" ON document_risk_analyses;
CREATE POLICY "Users can delete own risk analyses" ON document_risk_analyses
  FOR DELETE USING (
    document_id IN (
      SELECT id FROM user_documents WHERE user_id = auth.uid()
    )
  );

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_document_risk_analyses_document_id ON document_risk_analyses (document_id);

-- Storage RLS policies for contract_iq bucket
-- RLS is already enabled on storage.objects by default in Supabase

-- Drop and recreate storage policies
DROP POLICY IF EXISTS "Users can upload own files" ON storage.objects;
CREATE POLICY "Users can upload own files" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'contract_iq'
    AND auth.uid()::text = split_part(name::text, '/', 1)
  );

DROP POLICY IF EXISTS "Users can view own files" ON storage.objects;
CREATE POLICY "Users can view own files" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'contract_iq'
    AND auth.uid()::text = split_part(name::text, '/', 1)
  );

DROP POLICY IF EXISTS "Users can delete own files" ON storage.objects;
CREATE POLICY "Users can delete own files" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'contract_iq'
    AND auth.uid()::text = split_part(name::text, '/', 1)
  );

DROP POLICY IF EXISTS "Public can download files" ON storage.objects;
CREATE POLICY "Public can download files" ON storage.objects
  FOR SELECT USING (bucket_id = 'contract_iq');

  