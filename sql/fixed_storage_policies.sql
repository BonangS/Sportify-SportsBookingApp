-- Improved RLS Policies for the "images" bucket

-- Allow authenticated users to upload files
CREATE POLICY "Allow authenticated uploads" 
ON storage.objects 
FOR INSERT 
TO authenticated 
WITH CHECK (bucket_id = 'images');

-- Allow authenticated users to update their own files
-- Using USING for read access check and WITH CHECK for write access check
CREATE POLICY "Allow authenticated updates"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'images')
WITH CHECK (
  bucket_id = 'images' AND 
  name LIKE 'profile_%' || auth.uid() || '%'
);

-- Allow public access to read files (if images should be public)
-- This policy is fine as is
CREATE POLICY "Allow public read access"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'images');

-- Allow users to delete their own files
-- Fixed the pattern matching for profile pictures
CREATE POLICY "Allow authenticated deletes"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'images' AND
  name LIKE 'profile_%' || auth.uid() || '%'
);

-- ALTERNATIVE BROADER PERMISSIONS (if the above doesn't work)
-- These policies allow authenticated users to manage all their uploads

/*
-- Simple policy for uploads (all authenticated users)
CREATE POLICY "Allow authenticated users to upload files"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'images');

-- Simple policy for updates (all authenticated users)
CREATE POLICY "Allow authenticated users to update any file"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'images')
WITH CHECK (bucket_id = 'images');

-- Simple policy for deletes (all authenticated users)
CREATE POLICY "Allow authenticated users to delete any file"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'images');
*/
