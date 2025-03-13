#!/bin/bash 
#######################################
# New file in the active finder window 
# author  :  zbrl
# site    :  zhaozhang.net
#######################################

if [[ -z "${out_dir}" ]]; then
  out_dir=${HOME}"/Desktop/"
fi
out_path="${out_dir}${filename}"

extension=""
if [[ "$filename" == *.* && "$filename" != .* ]]; then
  extension="${filename##*.}"
fi

if [[ -z "${template}" ]]; then
  if [[ "$filename" == .* ]]; then
    template=$(find "${src_dir}" -type f -name "${filename}" -print)
  else
    template=$(find "${src_dir}" -type f -name "*.${extension}" -print)
  fi
fi

if [[ -f "${out_path}" ]]; then
  echo "${filename} already exists"
else
  if [[ -n "$extension" || "$filename" == .* ]]; then
    if [[ -z "$template" ]]; then
      echo "Failed! Unsupported file type, please add template file first."
    elif [[ $(echo "$template" | wc -l) -eq 1 ]]; then
      cp "$template" "$out_path"
      echo "${filename} created in ${out_dir}"
      open "${out_dir}"
    else
      echo "{\"items\": ["
      items=()
      while IFS= read -r template_item; do
          relative_path="${template_item#${src_dir}/}"
          template_uid=$(basename "$template_item")
          items+=( "{\"uid\": \"${template_uid}\", \"type\": \"file\", \"title\": \"${filename}\", \"subtitle\": \"../${relative_path}\", \"arg\": \"${template_item}\"}" )
      done <<< "$template"
      for (( i=0; i<${#items[@]}; i++ )); do
        if [[ $i -lt $((${#items[@]} - 1)) ]]; then
          printf "%s,\n" "${items[i]}"
        else
          printf "%s\n" "${items[i]}"
        fi
      done
      echo "]}"
    fi
  else
    if [[ -d "${out_path}" ]]; then
      echo "The file ${filename} can't' be created without a file extension because a folder called ${filename} already exists in ${out_dir}. "
    else
      touch "${out_path}"
      echo "${filename} created in ${out_dir}"
    fi
    open "${out_dir}"
  fi
fi


