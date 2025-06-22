-- Create RLS Policies for the "images" bucket

-- Allow authenticated users to upload files
CREATE POLICY "Allow authenticated uploads" 
ON storage.objects 
FOR INSERT 
TO authenticated 
WITH CHECK (bucket_id = 'images');

-- Allow authenticated users to update their own files
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
CREATE POLICY "Allow public read access"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'images');

-- Allow users to delete their own files
CREATE POLICY "Allow authenticated deletes"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'images' AND
  name LIKE 'profile_%' || auth.uid() || '%'
);

-- If you want to restrict access by file types, you can use something like:
-- USING (bucket_id = 'images' AND LOWER(storage.extension(name)) IN ('jpg', 'jpeg', 'png', 'gif'))

-- To automatically assign ownership to files based on auth.uid()
-- Uncomment and execute this function if you want to track file ownership explicitly

/*
CREATE OR REPLACE FUNCTION storage.set_owner_on_upload()
RETURNS trigger AS $$
BEGIN
  NEW.owner := auth.uid();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER set_owner_on_upload
BEFORE INSERT ON storage.objects
FOR EACH ROW EXECUTE FUNCTION storage.set_owner_on_upload();
*/
