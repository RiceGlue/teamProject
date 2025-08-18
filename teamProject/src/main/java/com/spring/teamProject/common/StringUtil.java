package com.spring.teamProject.common;

import java.util.ArrayList;
import java.util.List;

public class StringUtil {
	public static List<String> StringSeparated(String value) {
	    List<String> result = new ArrayList<>();
	    if (value != null && !value.trim().isEmpty()) {
	        // 쉼표(,), 콜론(:), 물결(~) 중 하나 이상을 구분자로 사용
	        String[] parts = value.split("[,:~]+");
	        for (String part : parts) {
	            String trimmed = part.trim();
	            if (!trimmed.isEmpty()) {
	                result.add(trimmed);
	            }
	        }
	    }
	    return result;
	}

}
