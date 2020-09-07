package com.journaldev.spring.controller;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;

import javax.servlet.http.HttpServletRequest;

import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

/**
 * Handles requests for the application file upload requests
 */
@Controller
public class FileUploadController {

	private static final Logger logger = LoggerFactory.getLogger(FileUploadController.class);
	private static final String INPUT_PATH = "/mnt/data/input";
	private static final String OUTPUT_PATH = "/mnt/data/output";
	private static final String GET_SHEET_NUM_URL = "http://169.51.204.19:32310/getNumofSheets/";
	private static final String GET_CSV_URL = "http://169.51.204.19:31057/getcsvfile?csvfilename=Hackathon_Financial_Sample/Sector1.csv";

	/**
	 * Upload single file using Spring Controller
	 */
	@RequestMapping(value = "/processForm", params = "upload", method = RequestMethod.POST)
	public @ResponseBody ModelAndView uploadFileHandler(@RequestParam("file") MultipartFile file,
			HttpServletRequest request) {
		String uploadedFileName = null;
		uploadedFileName = file.getOriginalFilename();
		logger.info("name: " + uploadedFileName);
		if (!file.isEmpty()) {
			try {
				byte[] bytes = file.getBytes();
				logger.info("name: " + uploadedFileName);
				File dir = new File(INPUT_PATH + File.separator);
				if (!dir.exists())
					dir.mkdirs();

				File serverFile = new File(dir.getAbsolutePath() + File.separator + uploadedFileName);
				BufferedOutputStream stream = new BufferedOutputStream(new FileOutputStream(serverFile));
				stream.write(bytes);
				stream.close();
				request.setAttribute("message", "Upload the file successfully with file name as : " + uploadedFileName);
				request.setAttribute("fileName", uploadedFileName);
				return new ModelAndView("result");

			} catch (Exception ex) {
				request.setAttribute("message", "File Upload Failed:" + ex);
				return new ModelAndView("result");
			}
		} else {
			request.setAttribute("message", "Failed to upload: " + uploadedFileName + " : Empty file");
			return new ModelAndView("result");
		}
	}

	@RequestMapping(value = "/processFile", params = "fileName", method = RequestMethod.POST)
	public @ResponseBody String fileReader(@RequestParam("fileName") String fileName, HttpServletRequest request) {
		logger.info("File Name: " + fileName);
		String uploadedFileFolder = fileName.replace(".xlsx", "");
		logger.info("File Name: " + uploadedFileFolder);

		StringBuffer fileValidation = isUploadFileValidate(fileName);

		return " File Name :- " + fileName + "\n" + " File Validations : - " + fileValidation.toString() + "\n"
				+ " The processed file is available in /mnt/data/output/" + uploadedFileFolder + " directory";
	}

	/**
	 * @Request fileName Api call will return uploaded file is valid or not with
	 *          sheet count
	 */
	private static StringBuffer isUploadFileValidate(String fileName) {

		logger.info("file Name:" + fileName);
		StringBuffer stringBuffer = new StringBuffer();
		final String uri = GET_SHEET_NUM_URL + fileName;
		RestTemplate restTemplate = new RestTemplate();
		String resultObj = restTemplate.getForObject(uri, String.class);
		JSONObject jsonResObj = new JSONObject(resultObj);
		stringBuffer.append(" Is upload file Valid: " + jsonResObj.getString("valid"));
		stringBuffer.append(" No.of Sheets: " + jsonResObj.getInt("Sheets"));

		logger.info("API Response: " + stringBuffer.toString());

		return stringBuffer;
	}

	public String processFile(String uploadedFileName) {
		ArrayList<String> fileName = new ArrayList<String>();
		logger.info("inside processing");
		String[] names = null;
		String uploadedFileFolder = uploadedFileName.replace(".xlsx", "");
		logger.info("inside uploadedFilePath :- " + uploadedFileFolder);
		String rootPath = OUTPUT_PATH;// result
		File dir = new File(rootPath + File.separator + uploadedFileFolder);
		/*
		 * if (!dir.exists()) dir.mkdirs();
		 */ // todo some fail condition

		File serverFile = new File(dir.getAbsolutePath());

		logger.info("inside serverFile:- " + serverFile);
		// File dir = new File("C:/result/");
		names = serverFile.list();

		for (String file : names) {
			System.out.println(file);
			fileName.add(file);
		}
		logger.info("fileName :-" + fileName.toString());
		return fileName.toString();
	}

	@RequestMapping(value = "/processFile.ajax", method = RequestMethod.GET)
	public @ResponseBody String processFileHandler(@RequestParam("uploadedFileName") String uploadedFileName) {
		ArrayList<String> fileName = new ArrayList<String>();
		logger.info("inside processing");
		String[] names = null;
		String uploadedFileFolder = uploadedFileName.replace(".xlsx", "");
		logger.info("inside uploadedFilePath :- " + uploadedFileFolder);
		String rootPath = OUTPUT_PATH;// result
		File dir = new File(rootPath + File.separator + uploadedFileFolder);
		/*
		 * if (!dir.exists()) dir.mkdirs();
		 */ // todo some fail condition

		File serverFile = new File(dir.getAbsolutePath());

		logger.info("inside serverFile:- " + serverFile);
		// File dir = new File("C:/result/");
		names = serverFile.list();

		for (String file : names) {
			System.out.println(file);
			fileName.add(file);
		}
		logger.info("fileName :-" + fileName.toString());
		return fileName.toString();
	}

	@RequestMapping(value = "/viewFile.ajax", method = RequestMethod.GET)
	public @ResponseBody File viewFileHandler(@RequestParam("sheetName") String sheetName) {
		logger.info("inside processing");
		logger.info("sheetName:" + sheetName);
		final String uri = GET_CSV_URL;
		RestTemplate restTemplate = new RestTemplate();
		File file = restTemplate.getForObject(uri, File.class);

		// .exchange("http://localhost:8080/downloadFile", HttpMethod.GET, entity,
		// byte[].class);
		return file;
		/*
		 * RestTemplate restTemplate = new RestTemplate(); String resultObj =
		 * restTemplate.getForObject(uri, String.class); JSONObject jsonResObj = new
		 * JSONObject(resultObj); stringBuffer.append("Is upload file Valid: " +
		 * jsonResObj.getString("valid")); stringBuffer.append("No.of Sheets: " +
		 * jsonResObj.getInt("Sheets"));
		 * 
		 * logger.info("API Response: " + stringBuffer.toString());
		 * 
		 * logger.info("API Response: " + stringBuffer.toString());
		 * 
		 * ResponseBuilder response = null; return (ResponseBuilder) response;
		 */

	}

}
